import XCTest
@testable import Sweechat

class EntryViewModelTests: XCTestCase {
    private class EntryDelegateStub: EntryDelegate {
        var didLogin = false
        var didRegister = false

        func navigateToLogin() {
            didLogin = true
        }

        func navigateToRegistration() {
            didRegister = true
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

        XCTAssertTrue(delegateStub.didLogin)
    }

    func testDidTapRegistrationButton_callsDelegateRegistrationMethod() {
        sut.didTapRegistrationButton()

        XCTAssertTrue(delegateStub.didRegister)
    }
}
