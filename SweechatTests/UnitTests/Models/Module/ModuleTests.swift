import Combine
import XCTest
@testable import Sweechat

class ModuleTests: XCTestCase {
    private var sut: Module!

    override func setUp() {
        super.setUp()
        sut = Module(id: Identifier<Module>("1"),
                     name: "Test",
                     currentUser: User(id: Identifier<User>(stringLiteral: "1")),
                     currentUserPermission: ModulePermission.none)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
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

    func testSubscribeToChatRooms_callsFunctionOnChatRoomsChange() {
        var isFunctionCalled = false
        let function: ([ChatRoom]) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToChatrooms(function: function)
        sut.chatRooms = []

        XCTAssertTrue(isFunctionCalled)
    }

    func testSubscribeToMembers_callsFunctionOnMembersChange() {
        var isFunctionCalled = false
        let function: ([User]) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToMembers(function: function)
        sut.members = []

        XCTAssertTrue(isFunctionCalled)
    }

    func testUpdate_updatesModule() {
        let newModule = Module(id: Identifier<Module>("2"),
                               name: "Test2",
                               currentUser: User(id: Identifier<User>(stringLiteral: "2")),
                               currentUserPermission: ModulePermission.none,
                               profilePictureUrl: "")

        sut.update(module: newModule)

        XCTAssertEqual(sut.name, newModule.name)
        XCTAssertEqual(sut.profilePictureUrl, newModule.profilePictureUrl)
    }

    func testEquals_sameId_returnsTrue() {
        let newModule = Module(id: Identifier<Module>("1"),
                               name: "Test2",
                               currentUser: User(id: Identifier<User>(stringLiteral: "2")),
                               currentUserPermission: ModulePermission.none,
                               profilePictureUrl: "")

        XCTAssertEqual(sut, newModule)
    }

    func testEquals_differentId_returnsFalse() {
        let newModule = Module(id: Identifier<Module>("2"),
                               name: "Test2",
                               currentUser: User(id: Identifier<User>(stringLiteral: "2")),
                               currentUserPermission: ModulePermission.none,
                               profilePictureUrl: "")

        XCTAssertNotEqual(sut, newModule)
    }
}
