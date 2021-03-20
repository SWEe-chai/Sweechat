import XCTest
@testable import Sweechat

class AppViewModelTests: XCTestCase {
    private var sut: AppViewModel!

    override func setUp() {
        super.setUp()
        sut = AppViewModel()
    }

    override func tearDown() {
        sut = nil
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
        sut.navigateToChatRoomFromModule()

        XCTAssertEqual(sut.state, AppState.chatRoom)
    }

    func testNavigateToHome() {
        sut.navigateToHomeFromLoggedIn()

        XCTAssertEqual(sut.state, AppState.home)
    }

    func testNavigateToModule() {
        sut.navigateToModuleFromHome()

        XCTAssertEqual(sut.state, AppState.module)
    }

    func testNavigateToSettings() {
        sut.navigateToSettingsFromHome()

        XCTAssertEqual(sut.state, AppState.settings)
    }
}