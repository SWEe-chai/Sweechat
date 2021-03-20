import XCTest
@testable import Sweechat

class LoginViewModelTests: XCTestCase {
    private class ALAuthHandlerStub: ALAuthHandler {
        weak var delegate: ALAuthHandlerDelegate?
        var didFacebookSignIn = false
        var didGoogleSignIn = false
        var type: ALAuthHandlerType

        init(type: ALAuthHandlerType) {
            self.type = type
        }

        func initiateSignIn() {
            switch type {
            case .facebook:
                didFacebookSignIn = true
            case .google:
                didGoogleSignIn = true
            }
        }
    }

    private class ALAuthStub: ALAuth {
        var alAuthHandlerStub: ALAuthHandlerStub!

        override func getHandlerUI(type: ALAuthHandlerType) -> ALAuthHandler {
            alAuthHandlerStub
        }
    }

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

    private var alAuthStub: ALAuthStub!
    private var delegateStub: LoggedInDelegateStub!
    private var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        alAuthStub = ALAuthStub()
        delegateStub = LoggedInDelegateStub()
        sut = LoginViewModel(auth: alAuthStub)
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

    func testDidTapBackButton_callsDelegateEntryMethod() {
        sut.didTapBackButton()

        XCTAssertTrue(delegateStub.didNavigateToEntry)
    }

    func testDidGoogleLogin_callsAuthGoogleMethod() {
        let alAuthHandlerStub = ALAuthHandlerStub(type: .google)
        alAuthStub.alAuthHandlerStub = alAuthHandlerStub

        sut.didTapGoogleLogin()

        XCTAssertTrue(alAuthHandlerStub.didGoogleSignIn)
    }

    func testDidTapEntryButton_callsAuthFacebookMethod() {
        let alAuthHandlerStub = ALAuthHandlerStub(type: .facebook)
        alAuthStub.alAuthHandlerStub = alAuthHandlerStub

        sut.didTapFacebookLogin()

        XCTAssertTrue(alAuthHandlerStub.didFacebookSignIn)
    }
}
