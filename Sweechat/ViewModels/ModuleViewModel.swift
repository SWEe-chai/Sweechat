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
        "This is CS3217 - aka best mod"
    }

    func didTapChatRoomButton() {
        delegate?.navigateToChatRoom()
    }

    func didTapBackButton() {
        delegate?.navigateToHomeFromModule()
    }
}
