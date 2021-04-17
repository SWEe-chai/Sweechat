//
//  ChatRoomFacade.swift
//  Sweechat
//
//  Created by Agnes Natasya on 19/3/21.
//
import Foundation

protocol ChatRoomFacade {
    var delegate: ChatRoomFacadeDelegate? { get set }
    func save(_ message: Message)
    func uploadToStorage(data: Data, fileName: String, onCompletion: ((URL) -> Void)?)
    func loadNextBlockOfMessages(onCompletion: @escaping ([Message]) -> Void)
    func loadMessage(withId id: String, onCompletion: @escaping (Message?) -> Void)
    func loadMessagesUntil(_ time: Date, onCompletion: @escaping ([Message]) -> Void)
    func loadPublicKeyBundlesFromStorage(of: [User], onCompletion: ((([String: Data]) -> Void))?)
    func delete(_ message: Message)
}
