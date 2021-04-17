//
//  FirebaseModuleListFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 26/3/21.
//

import FirebaseFirestore
import os

class FirebaseModuleListFacade: ModuleListFacade {
    weak var delegate: ModuleListFacadeDelegate?

    private let user: User
    private let db = Firestore.firestore()
    private let moduleIdLength = 8
    private var modulesReference: CollectionReference?
    private var modulesListener: ListenerRegistration?
    private var userModulePairsReference: CollectionReference?
    private var currentUserModulesListener: ListenerRegistration?
    private var currentUserModulesQuery: Query?

    private var userId: Identifier<User> {
        user.id
    }

    // MARK: Initialization

    init(user: User) {
        self.user = user
        setUpConnectionToModuleList()
    }

    // MARK: ModuleListFacade

    func save(module: Module, userModulePermissions: [UserModulePermissionPair]) {
        saveModule(module)
        saveUserModulePermissions(userModulePermissions, for: module)
    }

    func joinModule(moduleId: Identifier<Module>) {
        runIfModuleExists(moduleId: moduleId) {
            let permissions = ModulePermission.student
            let pair = FirebaseUserModulePair(userId: self.userId, moduleId: moduleId, permissions: permissions)

            self.userModulePairsReference?.addDocument(
                data: FirebaseUserModulePairAdapter.convert(pair: pair)) { error in
                if let e = error {
                    os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                    return
                }
            }
        }
    }

    // MARK: Private Helper Methods

    private func setUpConnectionToModuleList() {
        if userId.val.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }

        setUpModulesReference()
        setUpUserModulePairsReference()
        setUpCurrentUserModulesQuery()

        self.loadModules(onCompletion: self.addListeners)
    }

    private func setUpModulesReference() {
        modulesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.modules)
    }

    private func setUpUserModulePairsReference() {
        userModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userModulePairs)
    }

    private func setUpCurrentUserModulesQuery() {
        currentUserModulesQuery = userModulePairsReference?
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId.val)
    }

    private func runIfModuleExists(moduleId: Identifier<Module>, onCompletion: (() -> Void)?) {
        modulesReference?.document(moduleId.val).getDocument { querySnapshot, _ in
            if let snapshot = querySnapshot, snapshot.exists {
                onCompletion?()
            }
        }
    }

    private func loadModules(onCompletion: (() -> Void)?) {
        currentUserModulesQuery?.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                os_log("Error loading modules (\(error?.localizedDescription ?? ""))")
                return
            }

            let modulePairs = documents.compactMap {
                FirebaseUserModulePairAdapter.convert(document: $0)
            }

            FirebaseModuleQuery.getModules(pairs: modulePairs, user: self.user) { modules in
                self.delegate?.insertAll(modules: modules)
            }

            onCompletion?()
        }
    }

    private func addListeners() {
        currentUserModulesListener = currentUserModulesQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates (\(error?.localizedDescription ?? ""))")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleUserModulePairDocumentChange(change)
            }
        }
    }

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }

    private func saveModule(_ module: Module) {
        // TODO: generate id using a synchronous call
        module.id = Identifier<Module>(val: randomString(length: moduleIdLength))

        modulesReference?.document(module.id.val).setData(FirebaseModuleAdapter.convert(module: module)) { error in
            if let e = error {
                os_log("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }

    private func saveUserModulePermissions(_ userModulePermissions: [UserModulePermissionPair], for module: Module) {
        for userModulePermission in userModulePermissions {
            let pair = FirebaseUserModulePair(userId: userModulePermission.userId,
                                              moduleId: module.id,
                                              permissions: userModulePermission.permissions)

            userModulePairsReference?.addDocument(data: FirebaseUserModulePairAdapter.convert(pair: pair)) { error in
                if let e = error {
                    os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                    return
                }
            }
        }
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        if let userModulePair = FirebaseUserModulePairAdapter.convert(document: change.document) {
            FirebaseModuleQuery.getModule(pair: userModulePair, user: user) { module in
                switch change.type {
                case .added:
                    self.delegate?.insert(module: module)
                case .removed:
                    self.delegate?.remove(module: module)
                default:
                    return
                }
            }
        }
    }
}
