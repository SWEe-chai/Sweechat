import XCTest
@testable import Sweechat

class HomeViewModelTests: XCTestCase {
    private class UserStub: User {
        init() {
            super.init(details: UserRepresentation(id: User.dummyUserId, name: User.dummyUserName,
                                                   profilePictureUrl: nil, isLoggedIn: true))
        }
    }

    private class HomeDelegateStub: HomeDelegate {
        var didNavigateToSettings = false
        var didNavigateToModule = false

        func navigateToSettingsFromHome() {
            didNavigateToSettings = true
        }

        func navigateToModuleFromHome() {
            didNavigateToModule = true
        }
    }

    private var delegateStub: HomeDelegateStub!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = HomeDelegateStub()
        sut = HomeViewModel(user: UserStub())
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapModuleButton_callsDelegateModuleMethod() {
        sut.didTapModuleButton()

        XCTAssertTrue(delegateStub.didNavigateToModule)
    }

    func testDidTapSettingsButton_callsDelegateSettingsMethod() {
        sut.didTapSettingsButton()

        XCTAssertTrue(delegateStub.didNavigateToSettings)
    }
}
