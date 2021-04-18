import FirebaseFirestore
import FirebaseStorage
import os

/**
 A utility class that queries the Firebase connection for `Module`s.
 */
class FirebaseModuleQuery {
    /// Retrieves the `Module` with the specified ID and `User` and executes the specified function on completion.
    /// - Parameters:
    ///   - moduleId: The specified module ID.
    ///   - user: The specified `User`.
    ///   - onCompletion: The specified function to run on completion.
    static func getModule(moduleId: Identifier<Module>, user: User, onCompletion: @escaping (Module) -> Void) {
        FirebaseUserModulePairQuery.getUserModulePair(moduleId: moduleId, userId: user.id) { pair in
            if let pair = pair {
                getModule(pair: pair, user: user) { module in
                    onCompletion(module)
                }
            }
        }
    }

    /// Retrieves the `Module` with the specified `FirebaseUserModulePair` and `User`,
    /// and executes the specified function on completion.
    /// - Parameters:
    ///   - pair: The specified `FirebaseUserModulePair`.
    ///   - user: The specified `User`.
    ///   - onCompletion: The specified function to run on completion.
    static func getModule(pair: FirebaseUserModulePair, user: User, onCompletion: @escaping (Module) -> Void) {
        getModules(pairs: [pair], user: user) { modules in
            if let module = modules.first {
                onCompletion(module)
            }
        }
    }

    /// Retrieves the `Module`s with the specified `FirebaseUserModulePair`s and `User`,
    /// and executes the specified function on completion.
    /// - Parameters:
    ///   - pair: The specified `FirebaseUserModulePair`s.
    ///   - user: The specified `User`.
    ///   - onCompletion: The specified function to run on completion.
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
