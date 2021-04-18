import Combine
import XCTest
@testable import Sweechat

class ChatRoomTests: XCTestCase {
    private var sut: ChatRoom!

    override func setUp() {
        super.setUp()
        sut = ChatRoom(id: Identifier<ChatRoom>(stringLiteral: "1"),
                       name: "Test",
                       ownerId: Identifier<User>(stringLiteral: "1"),
                       currentUser: User(id: Identifier<User>(stringLiteral: "1")),
                       currentUserPermission: ChatRoomPermission.all,
                       isStarred: true,
                       creationTime: Date())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCreateUnavailableInstance_returnsUserWithUnavailableDetails() {
        let unavailableChatRoom = ChatRoom.createUnavailableInstance()

        XCTAssertEqual(unavailableChatRoom.ownerId, ChatRoom.unavailableOwnerId)
        XCTAssertEqual(unavailableChatRoom.id, ChatRoom.unavailableChatRoomId)
        XCTAssertEqual(unavailableChatRoom.name, ChatRoom.unavailableChatRoomName)
    }

    func testSubscribeToMessages_callsFunctionOnMessagesChange() {
        var isFunctionCalled = false
        let function: ([Identifier<Message>: Message]) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToMessages(function: function)
        sut.messages = [:]

        XCTAssertTrue(isFunctionCalled)
    }

    func testSubscribeToEarlyLoadedMessages_callsFunctionOnEarlyLoadedMessagesChange() {
        var isFunctionCalled = false
        let function: ([Identifier<Message>: Message]) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToEarlyLoadedMessages(function: function)
        sut.earlyLoadedMessages = [:]

        XCTAssertTrue(isFunctionCalled)
    }

    func testSubscribeToAreAllMessagesLoaded_callsFunctionAreAllMessagesLoadedChange() {
        var isFunctionCalled = false
        let function: (Bool) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToAreAllMessagesLoaded(function: function)
        sut.areAllMessagesLoaded = false

        XCTAssertTrue(isFunctionCalled)
    }

    func testSubscribeToName_callsFunctionOnNameChange() {
        var isFunctionCalled = false
        let function: (String) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToName(function: function)
        sut.name = ""

        XCTAssertTrue(isFunctionCalled)
    }

    func testSubscribeToProfilePicture_callsFunctionOnProfilePictureUrlChange() {
        var isFunctionCalled = false
        let function: (String?) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToProfilePicture(function: function)
        sut.profilePictureUrl = ""

        XCTAssertTrue(isFunctionCalled)
    }

    func testGetUser_userInChatRoom_returnsUser() {
        let member = User(id: Identifier<User>(stringLiteral: "2"))
        sut.memberIdsToUsers[member.id] = member

        XCTAssertEqual(sut.getUser(userId: member.id), member)
    }

    func testGetUser_userNotInChatRoom_returnsUnavailableUser() {
        XCTAssertEqual(sut.getUser(userId: Identifier<User>(stringLiteral: "2")), User.createUnavailableInstance())
    }

    func testRemoveMessage_removesMessage() {
        let message = Message(id: Identifier<Message>(stringLiteral: "1"),
                              senderId: Identifier<User>(stringLiteral: "1"),
                              creationTime: Date(),
                              content: Data(),
                              type: MessageType.text,
                              receiverId: Identifier<User>(stringLiteral: "2"),
                              parentId: nil,
                              likers: Set<Identifier<User>>())
        sut.messages[message.id] = message

        sut.remove(message: message)

        XCTAssertFalse(sut.messages.keys.contains(where: { $0 == message.id }))
    }

    func testInsertMember_insertsMember() {
        let member = User(id: Identifier<User>(stringLiteral: "2"))

        sut.insert(member: member)

        XCTAssertTrue(sut.memberIdsToUsers.keys.contains(where: { $0 == member.id }))
    }

    func testRemoveMember_removesMember() {
        let member = User(id: Identifier<User>(stringLiteral: "2"))
        sut.memberIdsToUsers[member.id] = member

        sut.remove(member: member)

        XCTAssertFalse(sut.memberIdsToUsers.keys.contains(where: { $0 == member.id }))
    }

    func insertAllMembers_insertsAllMembers() {
        let member1 = User(id: Identifier<User>(stringLiteral: "2"))
        let member2 = User(id: Identifier<User>(stringLiteral: "3"))

        sut.insertAll(members: [member1, member2])

        XCTAssertTrue(sut.memberIdsToUsers.keys.contains(where: { $0 == member1.id }))
        XCTAssertTrue(sut.memberIdsToUsers.keys.contains(where: { $0 == member2.id }))
    }

    func testUpdate_updatesChatRoom() {
        let chatRoom = ChatRoom(id: Identifier<ChatRoom>(stringLiteral: "2"),
                                name: "Test2",
                                ownerId: Identifier<User>(stringLiteral: "2"),
                                currentUser: User(id: Identifier<User>(stringLiteral: "2")),
                                currentUserPermission: ChatRoomPermission.all,
                                isStarred: true,
                                creationTime: Date(),
                                profilePictureUrl: "Test")

        sut.update(chatRoom: chatRoom)

        XCTAssertEqual(sut.name, chatRoom.name)
        XCTAssertEqual(sut.profilePictureUrl, chatRoom.profilePictureUrl)
    }

    func testEquals_sameId_returnsTrue() {
        let chatRoom = ChatRoom(id: Identifier<ChatRoom>(stringLiteral: "1"),
                                name: "Test2",
                                ownerId: Identifier<User>(stringLiteral: "2"),
                                currentUser: User(id: Identifier<User>(stringLiteral: "2")),
                                currentUserPermission: ChatRoomPermission.all,
                                isStarred: true,
                                creationTime: Date(),
                                profilePictureUrl: "Test")

        XCTAssertEqual(sut, chatRoom)
    }

    func testEquals_differentId_returnsFalse() {
        let chatRoom = ChatRoom(id: Identifier<ChatRoom>(stringLiteral: "2"),
                                name: "Test2",
                                ownerId: Identifier<User>(stringLiteral: "2"),
                                currentUser: User(id: Identifier<User>(stringLiteral: "2")),
                                currentUserPermission: ChatRoomPermission.all,
                                isStarred: true,
                                creationTime: Date(),
                                profilePictureUrl: "Test")

        XCTAssertNotEqual(sut, chatRoom)
    }
}
