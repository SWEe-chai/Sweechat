import XCTest
@testable import Sweechat

class HomeViewModelIntegrationTests: XCTestCase {
    private var alLogInDetails: ALLoginDetails!
    private var appViewModel: AppViewModel!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        alLogInDetails = ALLoginDetails(id: "abc", name: "name", profilePictureUrl: "prettyBoi.com")
        appViewModel = AppViewModel()
        sut = HomeViewModel(user: User(details: UserRepresentation(id: "5", name: "me",
                                                                   profilePictureUrl: "me.com")))
        sut.delegate = appViewModel
    }

    override func tearDown() {
        alLogInDetails = nil
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapModuleButton_navigatesToModuleState() {
        appViewModel.signIn(withDetails: alLogInDetails)

        sut.didTapModuleButton()

        XCTAssertEqual(appViewModel.state, .module)
    }

    func testDidTapSettingsButton_navigatesToSettingsState() {
        appViewModel.signIn(withDetails: alLogInDetails)

        sut.didTapSettingsButton()

        XCTAssertEqual(appViewModel.state, .settings)
    }
}
