import XCTest
@testable import Sweechat

class RegistrationViewModelTests: XCTestCase {
    private class LoggedInDelegateStub: LoggedInDelegate {
        var didNavigateToHome = false
        var didNavigateToEntry = false

        func navigateToHomeFromLoggedIn() {
            didNavigateToHome = true
        }

        func navigateToEntryFromLoggedIn() {
            didNavigateToEntry = true
        }
    }

    private var delegateStub: LoggedInDelegateStub!
    private var sut: RegistrationViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = LoggedInDelegateStub()
        sut = RegistrationViewModel()
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapBackButton_callsDelegateEntryMethod() {
        sut.didTapBackButton()

        XCTAssertTrue(delegateStub.didNavigateToEntry)
    }

    func testDidTapHomeButton_callsDelegateHomeMethod() {
        sut.didTapHomeButton()

        XCTAssertTrue(delegateStub.didNavigateToHome)
    }
}
