import XCTest
@testable import Sweechat

class ChatRoomViewModelTests: XCTestCase {
    private class UserStub: User {
        init() {
            super.init(details: UserRepresentation(id: User.dummyUserId, name: User.dummyUserName,
                                                   profilePictureUrl: nil))
        }
    }

    private class ChatRoomDelegateStub: ChatRoomDelegate {
        var didNavigateToModule = false

        func navigateToModuleFromChatRoom() {
            didNavigateToModule = true
        }
    }

    private var delegateStub: ChatRoomDelegateStub!
    private var sut: ChatRoomViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = ChatRoomDelegateStub()
        sut = ChatRoomViewModel(id: "1", user: UserStub())
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapBackButton_callsDelegateModuleMethod() {
        sut.didTapBackButton()

        XCTAssertTrue(delegateStub.didNavigateToModule)
    }
}
