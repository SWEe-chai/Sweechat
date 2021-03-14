//
//  Message.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

protocol Message {
    var sender: Sender {get set}
    var id: UUID? { get }
    var sentDate: Date { get }
    var type: MessageType { get set }
}
