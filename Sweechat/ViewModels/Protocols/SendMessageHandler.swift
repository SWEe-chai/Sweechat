//
//  SendMessageHandler.swift
//  Sweechat
//
//  Created by Christian James Welly on 15/4/21.
//

protocol SendMessageHandler {
    func handleSendText(_ text: String, withParentMessageViewModel parentMessageViewModel: MessageViewModel?)
    func handleEditText(_ text: String, withEditedMessageViewModel editedMessageViewModel: MessageViewModel?)
    func handleSendImage(_ wrappedImage: Any?, withParentMessageViewModel parentMessageViewModel: MessageViewModel?)
    func handleSendVideo(_ mediaURL: Any?, withParentMessageViewModel parentMessageViewModel: MessageViewModel?)
}
