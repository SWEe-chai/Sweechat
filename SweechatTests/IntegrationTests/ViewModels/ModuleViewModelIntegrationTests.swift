import XCTest
@testable import Sweechat

class ModuleViewModelIntegrationTests: XCTestCase {
    private var alLogInDetails: ALLoginDetails!
    private var appViewModel: AppViewModel!
    private var sut: ModuleViewModel!

    override func setUp() {
        super.setUp()
        alLogInDetails = ALLoginDetails(id: "abc", name: "name", profilePictureUrl: "prettyBoi.com")
        appViewModel = AppViewModel()
        sut = ModuleViewModel()
        sut.delegate = appViewModel
    }

    override func tearDown() {
        alLogInDetails = nil
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapChatRoomButton_navigatesToChatRoomState() {
        appViewModel.signIn(withDetails: alLogInDetails)

        sut.didTapChatRoomButton()

        XCTAssertEqual(appViewModel.state, .chatRoom)
    }

    func testDidTapBackButton_navigatesToHomeState() {
        appViewModel.signIn(withDetails: alLogInDetails)

        sut.didTapBackButton()

        XCTAssertEqual(appViewModel.state, .home)
    }
}
