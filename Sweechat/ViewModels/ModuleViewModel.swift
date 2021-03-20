//
//  ModuleViewModel.swift
//  Sweechat
//
//  Created by Christian James Welly on 14/3/21.
//

import Foundation

class ModuleViewModel: ObservableObject {
    weak var delegate: ModuleDelegate?
    var text: String {
        "Module"
    }

    func tappedOnChatRoom() {
        // TODO: ADD ID TO THIS
        delegate?.navigateToChatRoom()
    }
}
