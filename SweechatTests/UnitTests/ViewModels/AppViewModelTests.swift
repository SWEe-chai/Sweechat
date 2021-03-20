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

        sut.navigateToEntry()

        XCTAssertEqual(sut.state, AppState.entry)
    }

    func testNavigateToLogin() {
        sut.navigateToLogin()

        XCTAssertEqual(sut.state, AppState.login)
    }

    func testNavigateToRegistration() {
        sut.navigateToRegistration()

        XCTAssertEqual(sut.state, AppState.registration)
    }

    func testNavigateToChatRoom() {
        sut.navigateToChatRoom()

        XCTAssertEqual(sut.state, AppState.chatRoom)
    }

    func testNavigateToHome() {
        sut.navigateToHome()

        XCTAssertEqual(sut.state, AppState.home)
    }

    func testNavigateToModule() {
        sut.navigateToModule()

        XCTAssertEqual(sut.state, AppState.module)
    }

    func testNavigateToSettings() {
        sut.navigateToSettings()

        XCTAssertEqual(sut.state, AppState.settings)
    }
}
