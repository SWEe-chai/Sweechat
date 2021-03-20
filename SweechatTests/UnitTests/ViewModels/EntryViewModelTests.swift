import XCTest
@testable import Sweechat

class EntryViewModelTests: XCTestCase {
    private class EntryDelegateStub: EntryDelegate {
        var didNavigateToLogin = false
        var didNavigateToRegistration = false

        func navigateToLogin() {
            didNavigateToLogin = true
        }

        func navigateToRegistration() {
            didNavigateToRegistration = true
        }
    }

    private var delegateStub: EntryDelegateStub!
    private var sut: EntryViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = EntryDelegateStub()
        sut = EntryViewModel()
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapLoginButton_callsDelegateLoginMethod() {
        sut.didTapLoginButton()

        XCTAssertTrue(delegateStub.didNavigateToLogin)
    }

    func testDidTapRegistrationButton_callsDelegateRegistrationMethod() {
        sut.didTapRegistrationButton()

        XCTAssertTrue(delegateStub.didNavigateToRegistration)
    }
}
