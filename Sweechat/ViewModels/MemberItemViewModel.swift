//
//  MemberListViewModel.swift
//  Sweechat
//
//  Created by Agnes Natasya on 28/3/21.
//

import Combine

class MemberItemViewModel: ObservableObject {
    var member: User
    @Published var memberName: String
    
    init(member: User) {
        self.member = member
        self.memberName = member.name
    }
}
