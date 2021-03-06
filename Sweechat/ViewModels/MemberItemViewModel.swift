//
//  MemberListViewModel.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import Combine

class MemberItemViewModel: ObservableObject {
    let member: User

    @Published var isSelected: Bool
    @Published var memberName: String
    @Published var profilePictureUrl: String?

    // MARK: Initialization

    init(member: User) {
        self.member = member
        self.memberName = member.name
        self.profilePictureUrl = member.profilePictureUrl
        self.isSelected = false
    }

    func toggleSelection() {
        isSelected.toggle()
    }
}

// MARK: Identifiable
extension MemberItemViewModel: Identifiable {
}
