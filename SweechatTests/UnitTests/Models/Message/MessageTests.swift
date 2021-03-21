import XCTest
@testable import Sweechat

class MessageTests: XCTestCase {
    private class UserStub: User {
        init() {
            super.init(details: UserRepresentation(id: User.dummyUserId, name: User.dummyUserName,
                                                   profilePictureUrl: nil))
        }
    }

    func testEquals_sameMessage_returnsTrue() {
        let message = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")

        XCTAssertTrue(message == message)
    }

    func testEquals_twoMessagesWithSameId_returnsTrue() {
        let message1 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content1")
        let message2 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content2")

        XCTAssertTrue(message1 == message2)
    }

    func testEquals_twoMessagesWithDifferentIds_returnsFalse() {
        let message1 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")
        let message2 = Message(id: "2", sender: UserStub(), creationTime: Date(), content: "content")

        XCTAssertFalse(message1 == message2)
    }

    func testLessThan_sameMessage_returnsFalse() {
        let message = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")

        XCTAssertFalse(message < message)
    }

    func testLessThan_twoMessagesWithEqualCreationTimes_returnsFalse() {
        let creationTime = Date()
        let message1 = Message(id: "1", sender: UserStub(), creationTime: creationTime, content: "content")
        let message2 = Message(id: "1", sender: UserStub(), creationTime: creationTime, content: "content")

        XCTAssertFalse(message1 < message2)
    }

    func testLessThan_calledFromMessageWithGreaterCreationTime_returnsFalse() {
        let message1 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")
        let message2 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")

        XCTAssertFalse(message2 < message1)
    }

    func testLessThan_calledFromMessageWithSmallerCreationTime_returnsTrue() {
        let message1 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")
        let message2 = Message(id: "1", sender: UserStub(), creationTime: Date(), content: "content")

        XCTAssertTrue(message1 < message2)
    }
}
