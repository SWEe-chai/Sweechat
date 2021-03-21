import XCTest
@testable import Sweechat

class EntryViewModelIntegrationTests: XCTestCase {
    private var appViewModel: AppViewModel!
    private var sut: EntryViewModel!

    override func setUp() {
        super.setUp()
        appViewModel = AppViewModel()
        sut = EntryViewModel()
        sut.delegate = appViewModel
    }

    override func tearDown() {
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapLoginButton_navigatesToLoginState() {
        sut.didTapLoginButton()

        XCTAssertEqual(appViewModel.state, .login)
    }

    func testDidTapRegistrationButton_navigatesToRegistrationState() {
        sut.didTapRegistrationButton()

        XCTAssertEqual(appViewModel.state, .registration)
    }
}
