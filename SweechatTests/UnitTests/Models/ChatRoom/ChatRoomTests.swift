import XCTest
@testable import Sweechat

class ChatRoomTests: XCTestCase {
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
    private let messageStub3 = Message(sender: UserStub(), content: "3")
    private var sut: ChatRoom!

    override func setUp() {
        super.setUp()
        sut = ChatRoom()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInsert_emptyMessagesArray_appendsMessageToArray() {
        sut.insert(message: messageStub1)

        XCTAssertTrue(sut.messages.count == 1)
        XCTAssertTrue(sut.messages[0] == messageStub1)
    }

    func testInsert_messagesArrayWithOneMessage_appendsMessageToArray() {
        sut = ChatRoom(id: "1", messages: [messageStub1])
        sut.insert(message: messageStub2)

        XCTAssertTrue(sut.messages.count == 2)
        XCTAssertTrue(sut.messages[1] == messageStub2)
    }

    func testInsert_messagesArrayWithMultipleMessages_appendsMessageToArray() {
        sut = ChatRoom(id: "1", messages: [messageStub1, messageStub2])
        sut.insert(message: messageStub3)

        XCTAssertTrue(sut.messages.count == 3)
        XCTAssertTrue(sut.messages[2] == messageStub3)
    }

    func testInsert_multipleCalls_appendsMessagesToArrayInOrder() {
        sut.insert(message: messageStub1)
        sut.insert(message: messageStub2)
        sut.insert(message: messageStub3)

        XCTAssertTrue(sut.messages.count == 3)
        XCTAssertTrue(sut.messages[0] == messageStub1)
        XCTAssertTrue(sut.messages[1] == messageStub2)
        XCTAssertTrue(sut.messages[2] == messageStub3)
    }

    func testInsertAll_singleMessage_appendsMessageToArrayInOrder() {
        let messages = [messageStub1]

        sut.insertAll(messages: messages)

        XCTAssertEqual(sut.messages, messages)
    }

    func testInsertAll_multipleMessages_appendsMessagesToArrayInOrder() {
        let messages = [messageStub1, messageStub2, messageStub3]

        sut.insertAll(messages: messages)

        XCTAssertEqual(sut.messages, messages)
    }

    func testInsertAll_multipleOutOfOrderMessages_appendsMessagesToArrayInOrder() {
        let messages = [messageStub3, messageStub2, messageStub1]

        sut.insertAll(messages: messages)

        XCTAssertTrue(sut.messages.count == 3)
        XCTAssertTrue(sut.messages[0] == messageStub1)
        XCTAssertTrue(sut.messages[1] == messageStub2)
        XCTAssertTrue(sut.messages[2] == messageStub3)
    }
}
