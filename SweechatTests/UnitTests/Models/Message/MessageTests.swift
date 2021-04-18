import Combine
import XCTest
@testable import Sweechat

class MessageTests: XCTestCase {
    private var sut: Message!

    override func setUp() {
        super.setUp()
        sut = Message(id: Identifier<Message>(stringLiteral: "1"),
                      senderId: Identifier<User>(stringLiteral: "1"),
                      creationTime: Date(),
                      content: Data(),
                      type: MessageType.text,
                      receiverId: Identifier<User>(stringLiteral: "2"),
                      parentId: nil,
                      likers: Set<Identifier<User>>())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCopy_returnsMessageWithIdenticalFields() {
        let copy = sut.copy()

        XCTAssertEqual(sut.id, copy.id)
        XCTAssertEqual(sut.senderId, copy.senderId)
        XCTAssertEqual(sut.content, copy.content)
        XCTAssertEqual(sut.type, copy.type)
        XCTAssertEqual(sut.receiverId, copy.receiverId)
        XCTAssertEqual(sut.parentId, copy.parentId)
        XCTAssertEqual(sut.creationTime, copy.creationTime)
        XCTAssertEqual(sut.likers, copy.likers)
    }

    func testUpdate_updatesMessage() {
        let newMessage = Message(id: Identifier<Message>(stringLiteral: "1"),
                                 senderId: Identifier<User>(stringLiteral: "2"),
                                 creationTime: Date(),
                                 content: Data(),
                                 type: MessageType.image,
                                 receiverId: Identifier<User>(stringLiteral: "3"),
                                 parentId: "4",
                                 likers: Set<Identifier<User>>([Identifier<User>(stringLiteral: "5")]))

        sut.update(message: newMessage)

        XCTAssertEqual(sut.content, newMessage.content)
        XCTAssertEqual(sut.likers, newMessage.likers)
    }

    func testToggleLike_userNotInLikers_addsUserToLikers() {
        let userId = Identifier<User>(stringLiteral: "1")

        sut.toggleLike(of: userId)

        XCTAssertTrue(sut.likers.contains(userId))
    }

    func testToggleLike_userInLikers_removesUserFromLikers() {
        let userId = Identifier<User>(stringLiteral: "1")
        sut.likers.insert(userId)

        sut.toggleLike(of: userId)

        XCTAssertFalse(sut.likers.contains(userId))
    }

    func testSubscribeToContent_callsFunctionOnContentChange() {
        var isFunctionCalled = false
        let function: (Data) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToContent(function: function)
        sut.content = Data()

        XCTAssertTrue(isFunctionCalled)
    }

    func testSubscribeToLikers_callsFunctionOnLikersChange() {
        var isFunctionCalled = false
        let function: (Set<Identifier<User>>) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToLikers(function: function)
        sut.likers = Set<Identifier<User>>()

        XCTAssertTrue(isFunctionCalled)
    }

    func testEquals_sameId_returnsTrue() {
        let newMessage = Message(id: Identifier<Message>(stringLiteral: "1"),
                                 senderId: Identifier<User>(stringLiteral: "2"),
                                 creationTime: Date(),
                                 content: Data(),
                                 type: MessageType.image,
                                 receiverId: Identifier<User>(stringLiteral: "3"),
                                 parentId: "4",
                                 likers: Set<Identifier<User>>([Identifier<User>(stringLiteral: "5")]))

        XCTAssertEqual(sut, newMessage)
    }

    func testEquals_differentId_returnsFalse() {
        let newMessage = Message(id: Identifier<Message>(stringLiteral: "2"),
                                 senderId: Identifier<User>(stringLiteral: "2"),
                                 creationTime: Date(),
                                 content: Data(),
                                 type: MessageType.image,
                                 receiverId: Identifier<User>(stringLiteral: "3"),
                                 parentId: "4",
                                 likers: Set<Identifier<User>>([Identifier<User>(stringLiteral: "5")]))

        XCTAssertNotEqual(sut, newMessage)
    }

    func testLessThan_sameMessage_returnsFalse() {
        XCTAssertFalse(sut < sut)
    }

    func testLessThan_earlierCreationTime_returnsTrue() {
        guard let newTime = Calendar.current.date(byAdding: .day, value: 1, to: sut.creationTime) else {
            XCTFail("New time creation should not fail")
            return
        }

        let newMessage = Message(id: Identifier<Message>(stringLiteral: "2"),
                                 senderId: Identifier<User>(stringLiteral: "2"),
                                 creationTime: newTime,
                                 content: Data(),
                                 type: MessageType.image,
                                 receiverId: Identifier<User>(stringLiteral: "3"),
                                 parentId: "4",
                                 likers: Set<Identifier<User>>([Identifier<User>(stringLiteral: "5")]))

        XCTAssertTrue(sut < newMessage)
    }

    func testLessThan_sameCreationTime_returnsTrue() {
        let newMessage = Message(id: Identifier<Message>(stringLiteral: "2"),
                                 senderId: Identifier<User>(stringLiteral: "2"),
                                 creationTime: sut.creationTime,
                                 content: Data(),
                                 type: MessageType.image,
                                 receiverId: Identifier<User>(stringLiteral: "3"),
                                 parentId: "4",
                                 likers: Set<Identifier<User>>([Identifier<User>(stringLiteral: "5")]))

        XCTAssertFalse(sut < newMessage)
    }

    func testLessThan_greaterCreationTime_returnsFalse() {
        guard let newTime = Calendar.current.date(byAdding: .day, value: -1, to: sut.creationTime) else {
            XCTFail("New time creation should not fail")
            return
        }

        let newMessage = Message(id: Identifier<Message>(stringLiteral: "2"),
                                 senderId: Identifier<User>(stringLiteral: "2"),
                                 creationTime: newTime,
                                 content: Data(),
                                 type: MessageType.image,
                                 receiverId: Identifier<User>(stringLiteral: "3"),
                                 parentId: "4",
                                 likers: Set<Identifier<User>>([Identifier<User>(stringLiteral: "5")]))

        XCTAssertFalse(sut < newMessage)
    }
}
