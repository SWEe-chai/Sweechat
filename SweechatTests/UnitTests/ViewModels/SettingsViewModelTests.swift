import XCTest
@testable import Sweechat

class SettingsViewModelTests: XCTestCase {
    private class SettingsDelegateStub: LoggedOutDelegate {
        var didNavigateToEntry = false
        var didNavigateToHome = false

        func navigateToEntryFromLoggedOut() {
            didNavigateToEntry = true
        }

        func navigateToHomeFromLoggedOut() {
            didNavigateToHome = true
        }
    }

    private var delegateStub: SettingsDelegateStub!
    private var sut: SettingsViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = SettingsDelegateStub()
        sut = SettingsViewModel()
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapLogoutButton_callsDelegateEntryMethod() {
        sut.didTapLogoutButton()

        XCTAssertTrue(delegateStub.didNavigateToEntry)
    }

    func testDidTapBackButton_callsDelegateBackMethod() {
        sut.didTapBackButton()

        XCTAssertTrue(delegateStub.didNavigateToHome)
    }
}
