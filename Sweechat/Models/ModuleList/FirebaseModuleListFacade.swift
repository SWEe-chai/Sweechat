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
    private var userId: String

    private var db = Firestore.firestore()
    private var modulesReference: CollectionReference?
    private var modulesListener: ListenerRegistration?
    private var userModulePairsReference: CollectionReference?
    private var currentUserModulesListener: ListenerRegistration?
    private var currentUserModulesQuery: Query?

    init(userId: String) {
        self.userId = userId
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
            let pair = FirebaseUserModulePair(userId: self.userId, moduleId: moduleId)
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
            guard let snapshot = querySnapshot else {
                os_log("Error loading chatRooms: \(error?.localizedDescription ?? "No error")")
                return
            }
            for document in snapshot.documents {
                let data = document.data()
                guard let moduleId = data[DatabaseConstant.UserModulePair.moduleId] as? String else {
                    return
                }
                self.modulesReference?
                    .document(moduleId)
                    .getDocument(completion: { documentSnapshot, error in
                        guard let snapshot = documentSnapshot else {
                            return
                        }

                        if let err = error {
                            os_log("Error getting chat rooms in module: \(err.localizedDescription)")
                            return
                        }
                        if let module = FirebaseModuleFacade.convert(document: snapshot) {
                            self.delegate?.insert(module: module)
                        }
                    }
                    )
            }
            onCompletion?()
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
        modulesListener = modulesReference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                os_log("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleModuleDocumentChange(change)
            }
        }
    }

    func save(module: Module) {
        // TODO: generate id using a synchronous call
        let id = randomString(length: 8)
        module.id = id

        modulesReference?.document(module.id).setData(FirebaseModuleFacade.convert(module: module)) { error in
            if let e = error {
                os_log("Error sending message: \(e.localizedDescription)")
                return
            }
        }

        for user in module.users {
            let pair = FirebaseUserModulePair(userId: user.id, moduleId: module.id)
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
        modulesReference?
            .document(userModulePair.moduleId)
            .getDocument(completion: { documentSnapshot, error in
                guard let snapshot = documentSnapshot else {
                    return
                }
                if let err = error {
                    os_log("Error getting users in module: \(err.localizedDescription)")
                    return
                }
                if let module = FirebaseModuleFacade.convert(document: snapshot) {
                    switch change.type {
                    case .added:
                        self.delegate?.insert(module: module)
                    case .removed:
                        self.delegate?.remove(module: module)
                    default:
                        break
                    }
                }
            })
    }

    private func handleModuleDocumentChange(_ change: DocumentChange) {
        if let module = FirebaseModuleFacade.convert(document: change.document) {
            modulesReference?
                .document(module.id)
                .getDocument(completion: { documentSnapshot, error in
                    guard documentSnapshot != nil else {
                        return
                    }
                    if let err = error {
                        os_log("Error getting sender in message: \(err.localizedDescription)")
                        return
                    }

                    switch change.type {
                    case .modified:
                        self.delegate?.update(module: module)
                    default:
                        break
                    }
                })
        }

    }
}
