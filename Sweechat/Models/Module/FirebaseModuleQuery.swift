import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseModuleQuery {
    static func getModule(moduleId: Identifier<Module>, user: User, onCompletion: @escaping (Module) -> Void) {
        FirebaseUserModulePairQuery.getUserModulePair(moduleId: moduleId, userId: user.id) { pair in
            if let pair = pair {
                getModule(pair: pair, user: user) { module in
                    onCompletion(module)
                }
            }
        }
    }

    static func getModule(pair: FirebaseUserModulePair, user: User, onCompletion: @escaping (Module) -> Void) {
        getModules(pairs: [pair], user: user) { modules in
            if let module = modules.first {
                onCompletion(module)
            }
        }
    }

    static func getModules(pairs: [FirebaseUserModulePair], user: User, onCompletion: @escaping ([Module]) -> Void) {
        let moduleIdStrings = pairs.map { $0.moduleId.val }

        if moduleIdStrings.isEmpty {
            onCompletion([])
            return
        }

        for moduleIdStringsChunk in moduleIdStrings.chunked(into: FirebaseUtils.queryChunkSize) {
            FirebaseUtils
                .getEnvironmentReference(Firestore.firestore())
                .collection(DatabaseConstant.Collection.modules)
                .whereField(DatabaseConstant.Module.id, in: moduleIdStringsChunk)
                .getDocuments { snapshots, error in
                    guard let documents = snapshots?.documents else {
                        os_log("Error getting modules from: \(pairs)")
                        os_log("Error getting modules (\(error?.localizedDescription ?? ""))")
                        return
                    }

                    let modules: [Module] = documents.compactMap { document in
                        guard let moduleIdStr = document[DatabaseConstant.Module.id] as? String,
                              let pair = pairs.first(where: { $0.moduleId.val == moduleIdStr }) else {
                            os_log("Unable to find pair with the desired moduleId. Document: %s",
                                   String(describing: document))
                            return nil
                        }

                        return FirebaseModuleAdapter.convert(document: document,
                                                             user: user,
                                                             withPermissions: pair.permissions)
                    }

                    onCompletion(modules)
                }
        }
    }
}
