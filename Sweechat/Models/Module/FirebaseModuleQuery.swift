import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseModuleQuery {
    static func getModule(moduleId: String,
                          user: User,
                          onCompletion: @escaping (Module) -> Void) {
        FirebaseUserModulePairQuery
            .getUserModulePair(moduleId: moduleId, userId: user.id) { pair in
                guard let pair = pair else {
                    return
                }
                getModule(pair: pair, user: user) { module in
                    onCompletion(module)
                }
            }
    }

    static func getModule(pair: FirebaseUserModulePair, user: User, onCompletion: @escaping (Module) -> Void) {
        getModules(pairs: [pair], user: user) { modules in
            guard let module = modules.first else {
                return
            }
            onCompletion(module)
        }
    }

    static func getModules(pairs: [FirebaseUserModulePair], user: User, onCompletion: @escaping ([Module]) -> Void) {
        let moduleIds = pairs.map { $0.moduleId }
        if moduleIds.isEmpty {
            onCompletion([])
            return
        }
        for moduleIdChunk in moduleIds.chunked(into: 10) {
            FirebaseUtils
                .getEnvironmentReference(Firestore.firestore())
                .collection(DatabaseConstant.Collection.modules)
                .whereField(DatabaseConstant.Module.id, in: moduleIdChunk)
                .getDocuments { snapshots, error in
                    guard let documents = snapshots?.documents else {
                        os_log("Error getting Modules from: \(pairs)")
                        os_log("Error \(error?.localizedDescription ?? "No error")")
                        return
                    }
                    let modules: [Module] = documents.compactMap { document in
                        guard let moduleId = document[DatabaseConstant.Module.id] as? String,
                              let pair = pairs.first(where: { $0.moduleId == moduleId }) else {
                            os_log("Unable to find pair with the desired moduleId. Document: %s",
                                   String(describing: document))
                            return nil
                        }
                        return FirebaseModuleFacade.convert(document: document,
                                                            user: user,
                                                            withPermissions: pair.permissions)
                    }
                    onCompletion(modules)
                }
        }
    }
}
