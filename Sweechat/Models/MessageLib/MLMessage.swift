//
//  Message.swift
//  Sweechat
//
//  Created by Agnes Natasya on 14/3/21.
//

import Foundation

protocol MLMessage {
    var sender: MLSender {get set}
    var id: String? { get }
    var creationTime: Date { get }
    var type: MLMessageType { get set }
}
