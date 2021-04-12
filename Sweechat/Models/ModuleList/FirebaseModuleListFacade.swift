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
    private var user: User
    private var userId: String { user.id }

    private var db = Firestore.firestore()
    private var modulesReference: CollectionReference?
    private var modulesListener: ListenerRegistration?
    private var userModulePairsReference: CollectionReference?
    private var currentUserModulesListener: ListenerRegistration?
    private var currentUserModulesQuery: Query?

    init(user: User) {
        self.user = user
        setUpConnectionToModuleList()
    }

    func setUpConnectionToModuleList() {
        if userId.isEmpty {
            os_log("Error loading Chat Room: Chat Room id is empty")
            return
        }
        modulesReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.modules)
        userModulePairsReference = FirebaseUtils
            .getEnvironmentReference(db)
            .collection(DatabaseConstant.Collection.userModulePairs)
        currentUserModulesQuery = userModulePairsReference?
            .whereField(DatabaseConstant.UserModulePair.userId, isEqualTo: userId)
        self.loadModules(onCompletion: self.addListeners)
    }

    func joinModule(moduleId: String) {
        runIfModuleExists(moduleId: moduleId) {
            let permissions = ModulePermission.student
            let pair = FirebaseUserModulePair(userId: self.userId,
                                              moduleId: moduleId,
                                              permissions: permissions)
            self.userModulePairsReference?.addDocument(
                data: FirebaseUserModulePairFacade.convert(pair: pair)) { error in
                if let e = error {
                    os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                    return
                }
            }
        }
    }

    func runIfModuleExists(moduleId: String, onCompletion: (() -> Void)?) {
        modulesReference?.document(moduleId).getDocument { querySnapshot, _ in
            if let snapshot = querySnapshot,
               snapshot.exists {
                onCompletion?()
            }
        }
    }

    private func loadModules(onCompletion: (() -> Void)?) {
        currentUserModulesQuery?.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                os_log("Error loading chatRooms: \(error?.localizedDescription ?? "No error")")
                return
            }
            let modulePairs = documents.compactMap {
                FirebaseUserModulePairFacade.convert(document: $0)
            }
            FirebaseModuleQuery.getModules(pairs: modulePairs, user: self.user) { modules in
                self.delegate?.insertAll(modules: modules)
                onCompletion?()
            }
        }
    }

    private func addListeners() {
        currentUserModulesListener = currentUserModulesQuery?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleUserModulePairDocumentChange(change)
            }
        }
    }

    func save(module: Module, userModulePermissions: [UserModulePermissionPair]) {
        // TODO: generate id using a synchronous call
        let id = randomString(length: 8)
        module.id = Identifier<Module>(val: id)

        modulesReference?.document(module.id.val).setData(FirebaseModuleFacade.convert(module: module)) { error in
            if let e = error {
                os_log("Error sending message: \(e.localizedDescription)")
                return
            }
        }

        for userModulePermission in userModulePermissions {
            let pair = FirebaseUserModulePair(userId: userModulePermission.userId,
                                              moduleId: module.id.val,
                                              permissions: userModulePermission.permissions)
            userModulePairsReference?.addDocument(data: FirebaseUserModulePairFacade.convert(pair: pair)) { error in
                if let e = error {
                    os_log("Error sending userChatRoomPair: \(e.localizedDescription)")
                    return
                }
            }
        }
    }

    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map { _ in letters.randomElement()! })
    }

    private func handleUserModulePairDocumentChange(_ change: DocumentChange) {
        guard let userModulePair = FirebaseUserModulePairFacade.convert(document: change.document) else {
            return
        }
        FirebaseModuleQuery.getModule(pair: userModulePair, user: user) { module in
            switch change.type {
            case .added:
                self.delegate?.insert(module: module)
            case .removed:
                self.delegate?.remove(module: module)
            default:
                break
            }
        }
    }
}
