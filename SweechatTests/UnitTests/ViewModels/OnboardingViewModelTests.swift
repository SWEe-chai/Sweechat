import XCTest
@testable import Sweechat

class OnboardingViewModelTests: XCTestCase {
    private class LoggedOutDelegateStub: LoggedOutDelegate {
        var didNavigateToEntry = false

        func navigateToEntry() {
            didNavigateToEntry = true
        }
    }

    private var delegateStub: LoggedOutDelegateStub!
    private var sut: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        delegateStub = LoggedOutDelegateStub()
        sut = OnboardingViewModel()
        sut.delegate = delegateStub
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDidTapEntryButton_callsDelegateENtryMethod() {
        sut.didTapEntryButton()

        XCTAssertTrue(delegateStub.didNavigateToEntry)
    }
}
