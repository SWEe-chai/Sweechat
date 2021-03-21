import XCTest
@testable import Sweechat

class ChatRoomViewModelIntegrationTests: XCTestCase {
    private var alLogInDetails: ALLoginDetails!
    private var appViewModel: AppViewModel!
    private var sut: ChatRoomViewModel!

    override func setUp() {
        super.setUp()
        alLogInDetails = ALLoginDetails(id: "abc", name: "name", profilePictureUrl: "prettyBoi.com")
        appViewModel = AppViewModel()
        sut = ChatRoomViewModel(id: "1", user: User(details: UserRepresentation(id: "5", name: "me",
                                                                                profilePictureUrl: "me.com")))
        sut.delegate = appViewModel
    }

    override func tearDown() {
        appViewModel = nil
        alLogInDetails = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapBackButton_navigatesToModuleState() {
        appViewModel.signIn(withDetails: alLogInDetails)

        sut.didTapBackButton()

        XCTAssertEqual(appViewModel.state, .module)
    }
}
