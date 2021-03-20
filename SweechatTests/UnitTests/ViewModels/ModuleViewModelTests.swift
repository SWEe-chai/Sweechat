import XCTest
@testable import Sweechat

class ModuleViewModelTests: XCTestCase {
    private class ModuleDelegateStub: ModuleDelegate {
        var didNavigateToChatRoom = false
        var didNavigateToHome = false

        func navigateToChatRoomFromModule() {
            didNavigateToChatRoom = true
        }

        func navigateToHomeFromModule() {
            didNavigateToHome = true
        }
    }

    private var delegateStub: ModuleDelegateStub!
    private var sut: ModuleViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = ModuleDelegateStub()
        sut = ModuleViewModel()
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapChatRoomButton_callsDelegateChatRoomMethod() {
        sut.didTapChatRoomButton()

        XCTAssertTrue(delegateStub.didNavigateToChatRoom)
    }

    func testDidTapBackButton_callsDelegateHomeMethod() {
        sut.didTapBackButton()

        XCTAssertTrue(delegateStub.didNavigateToHome)
    }
}
