import XCTest
@testable import Sweechat

class MessageViewModelTests: XCTestCase {
    private class UserStub: User {
        init() {
            super.init(details: UserRepresentation(
                        id: "",
                        name: "",
                        profilePictureUrl: nil))
        }
    }

    private let messageStub1 = Message(sender: UserStub(), content: "1")
    private let messageStub2 = Message(sender: UserStub(), content: "2")

    func testEquals_sameMessageViewModel_returnsTrue() {
        let messageViewModel = MessageViewModel(message: messageStub1, isCurrentUser: false)

        XCTAssertTrue(messageViewModel == messageViewModel)
    }

    func testEquals_messageViewModelsWithTheSameMessage_returnsTrue() {
        let messageViewModel1 = MessageViewModel(message: messageStub1, isCurrentUser: false)
        let messageViewModel2 = MessageViewModel(message: messageStub1, isCurrentUser: false)

        XCTAssertTrue(messageViewModel1 == messageViewModel2)
    }

    func testEquals_messageViewModelsWithDifferentMessages_returnsFalse() {
        let messageViewModel1 = MessageViewModel(message: messageStub1, isCurrentUser: false)
        let messageViewModel2 = MessageViewModel(message: messageStub2, isCurrentUser: false)

        XCTAssertFalse(messageViewModel1 == messageViewModel2)
    }

    func testHash_sameMessageViewModel_returnsSameHashValue() {
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        let messageViewModel = MessageViewModel(message: messageStub1, isCurrentUser: false)

        messageViewModel.hash(into: &hasher1)
        messageViewModel.hash(into: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testHash_messageViewModelsWithTheSameMessage_returnsSameHashValue() {
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        let messageViewModel1 = MessageViewModel(message: messageStub1, isCurrentUser: false)
        let messageViewModel2 = MessageViewModel(message: messageStub1, isCurrentUser: false)

        messageViewModel1.hash(into: &hasher1)
        messageViewModel2.hash(into: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testHash_messageViewModelsWithDifferentMessages_returnsSameHashValue() {
        var hasher1 = Hasher()
        var hasher2 = Hasher()
        let messageViewModel1 = MessageViewModel(message: messageStub1, isCurrentUser: false)
        let messageViewModel2 = MessageViewModel(message: messageStub2, isCurrentUser: false)

        messageViewModel1.hash(into: &hasher1)
        messageViewModel2.hash(into: &hasher2)

        XCTAssertNotEqual(hasher1.finalize(), hasher2.finalize())
    }
}
