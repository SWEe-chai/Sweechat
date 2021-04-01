import FirebaseFirestore
import FirebaseStorage
import os

class FirebaseModuleQuery {
    static func getModule(pair: FirebaseUserModulePair, user: User, onCompletion: @escaping (Module) -> Void) {
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.modules)
            .document(pair.moduleId)
            .getDocument { snapshot, error in
                guard let document = snapshot else {
                    os_log("Error getting modules: Module with Id: \(pair.moduleId) does not exist")
                    os_log("Error \(error?.localizedDescription ?? "No error")")
                    return
                }
                guard let module = FirebaseModuleFacade
                        .convert(document: document,
                                 user: user) else {
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
        FirebaseUtils
            .getEnvironmentReference(Firestore.firestore())
            .collection(DatabaseConstant.Collection.modules)
            .whereField(DatabaseConstant.Module.id, in: moduleIds)
            .getDocuments { snapshots, error in
                guard let documents = snapshots?.documents else {
                    os_log("Error getting Modules from: \(pairs)")
                    os_log("Error \(error?.localizedDescription ?? "No error")")
                    return
                }
                let modules: [Module] = documents.compactMap { document in
                    FirebaseModuleFacade.convert(document: document, user: user)
                }
                onCompletion(modules)
            }
    }
}
