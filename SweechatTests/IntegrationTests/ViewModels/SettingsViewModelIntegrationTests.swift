import XCTest
@testable import Sweechat

class SettingsViewModelIntegrationTests: XCTestCase {
    private var alLogInDetails: ALLoginDetails!
    private var appViewModel: AppViewModel!
    private var sut: SettingsViewModel!

    override func setUp() {
        super.setUp()
        alLogInDetails = ALLoginDetails(id: "abc", name: "name", profilePictureUrl: "prettyBoi.com")
        appViewModel = AppViewModel()
        sut = SettingsViewModel()
        sut.delegate = appViewModel
    }

    override func tearDown() {
        alLogInDetails = nil
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapLogoutButton_navigatesToEntryState() {
        appViewModel.signIn(withDetails: alLogInDetails)
        appViewModel.user = nil

        sut.didTapLogoutButton()

        XCTAssertEqual(appViewModel.state, .entry)
    }

    func testDidTapBackButton_navigatesToHomeState() {
        appViewModel.signIn(withDetails: alLogInDetails)

        sut.didTapBackButton()

        XCTAssertEqual(appViewModel.state, .home)
    }
}
