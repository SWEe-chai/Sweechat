import XCTest
@testable import Sweechat

class RegistrationViewModelTests: XCTestCase {
    private class LoggedInDelegateStub: LoggedInDelegate {
        var didNavigateToHome = false

        func navigateToHome() {
            didNavigateToHome = true
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

    func testDidTapHomeButton_callsDelegateHomeMethod() {
        sut.didTapHomeButton()

        XCTAssertTrue(delegateStub.didNavigateToHome)
    }
}
