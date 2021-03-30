import SwiftUI
import Combine

class CreateChatRoomViewModel: ObservableObject {
    var module: Module
    var user: User
    var memberListener: AnyCancellable?

    var otherUsersViewModels: [MemberItemViewModel]

    @Published var isWritable: Bool = true

    init(module: Module, user: User, members: [User]) {
        self.module = module
        self.user = user
        self.otherUsersViewModels = members
            .filter { $0.id != user.id }
            .map { MemberItemViewModel(member: $0) }
    }

    func createPrivateGroupChatWith(memberViewModel: MemberItemViewModel) {
        // TODO: Implement creation
        print("create private chat with \(memberViewModel.memberName)")
    }

    func toggleIsWritable() {
        isWritable.toggle()
    }
}
