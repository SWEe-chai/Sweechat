import XCTest
@testable import Sweechat

class AppViewModelTests: XCTestCase {
    private var alLogInDetails: ALLoginDetails!
    private var sut: AppViewModel!

    override func setUp() {
        super.setUp()
        alLogInDetails = ALLoginDetails(id: "abc", name: "name", profilePictureUrl: "prettyBoi.com")
        sut = AppViewModel()
    }

    override func tearDown() {
        sut = nil
        alLogInDetails = nil
        super.tearDown()
    }

    func testNavigateToEntry() {
        sut.state = AppState.home // set some other initial state in AppVM

        sut.navigateToEntryFromLoggedOut()

        XCTAssertEqual(sut.state, AppState.entry)
    }

    func testNavigateToLogin() {
        sut.navigateToLoginFromEntry()

        XCTAssertEqual(sut.state, AppState.login)
    }

    func testNavigateToRegistration() {
        sut.navigateToRegistrationFromEntry()

        XCTAssertEqual(sut.state, AppState.registration)
    }

    func testNavigateToChatRoom() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToChatRoomFromModule()

        XCTAssertEqual(sut.state, AppState.chatRoom)
    }

    func testNavigateToHome() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToHomeFromLoggedIn()

        XCTAssertEqual(sut.state, AppState.home)
    }

    func testNavigateToModule() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToModuleFromHome()

        XCTAssertEqual(sut.state, AppState.module)
    }

    func testNavigateToSettings() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToSettingsFromHome()

        XCTAssertEqual(sut.state, AppState.settings)
    }
}
