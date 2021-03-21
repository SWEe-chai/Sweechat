import XCTest
@testable import Sweechat

class LoginViewModelIntegrationTests: XCTestCase {
    private var appViewModel: AppViewModel!
    private var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        appViewModel = AppViewModel()
        sut = LoginViewModel(auth: ALAuth())
        sut.delegate = appViewModel
    }

    override func tearDown() {
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapBackButton_callsDelegateEntryMethod() {
        sut.didTapBackButton()

        XCTAssertEqual(appViewModel.state, .entry)
    }
}
