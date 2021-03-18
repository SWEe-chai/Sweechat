//
//  ModuleViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import Foundation
import Firebase
import os

class ModuleViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private var reference: CollectionReference?

    @Published var module: Module {
        didSet {
            objectWillChange.send()
        }
    }
    private var chatRoomListener: ListenerRegistration?

    var name: String {
        module.name
    }

    init(id: String) {
        module = Module(id: id, name: DatabaseConstant.Module.defaultModuleName)
    }

    func connectToFirebase() {
        reference = db.collection([DatabaseConstant.Collection.modules,
                                   module.id,
                                   DatabaseConstant.Collection.chatRooms].joined(separator: "/"))

        chatRoomListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let chatRoom = ChatRoomAdapter.convert(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            insertNewChatRoom(chatRoom)
        default:
            print("not added with the change.type: \(change.type)")
        }
    }

    private func insertNewChatRoom(_ chatRoom: ChatRoom) {
        guard !module.chatRooms.contains(chatRoom) else {
            return
        }

        module.chatRooms.append(chatRoom)
    }
}
