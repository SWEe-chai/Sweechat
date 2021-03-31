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
    func uploadToStorage(fromURL url: URL, fileName: String, onCompletion: ((URL) -> Void)?)
}
