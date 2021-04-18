import Combine
import XCTest
@testable import Sweechat

class UserTests: XCTestCase {
    private var sut: User!

    override func setUp() {
        super.setUp()
        sut = User(id: Identifier<User>(stringLiteral: "1"))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCreateUnavailableInstance_returnsUserWithUnavailableDetails() {
        let unavailableUser = User.createUnavailableInstance()

        XCTAssertEqual(unavailableUser.id, User.unvailableUserId)
        XCTAssertEqual(unavailableUser.name, User.unvailableUserName)
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
}
