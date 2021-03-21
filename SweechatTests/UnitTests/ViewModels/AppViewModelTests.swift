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

    func testNavigateToEntry_validState_changesToEntryState() {
        sut.state = AppState.home // set some other initial state in AppVM

        sut.navigateToEntryFromLoggedOut()

        XCTAssertEqual(sut.state, AppState.entry)
    }

    func testNavigateToEntry_invalidState_changesToDefaultLoggedInState() {
        sut.signIn(withDetails: alLogInDetails)
        sut.state = AppState.module // set some other initial state in AppVM

        sut.navigateToEntryFromLoggedOut()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedInAppState)
    }

    func testNavigateToLogin_validState_changesToLoginState() {
        sut.navigateToLoginFromEntry()

        XCTAssertEqual(sut.state, AppState.login)
    }

    func testNavigateToLogin_invalidState_changesToDefaultLoggedInState() {
        sut.signIn(withDetails: alLogInDetails)

        sut.navigateToLoginFromEntry()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedInAppState)
    }

    func testNavigateToRegistration_validState_changesToRegistrationState() {
        sut.navigateToRegistrationFromEntry()

        XCTAssertEqual(sut.state, AppState.registration)
    }

    func testNavigateToRegistration_invalidState_changesToDefaultLoggedInState() {
        sut.signIn(withDetails: alLogInDetails)

        sut.navigateToRegistrationFromEntry()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedInAppState)
    }

    func testNavigateToChatRoom_validState_changesToChatRoomState() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToChatRoomFromModule()

        XCTAssertEqual(sut.state, AppState.chatRoom)
    }

    func testNavigateToChatRoom_invalidState_changesToDefaultLoggedOutState() {
        sut.state = AppState.login // set some other initial state in AppVM

        sut.navigateToChatRoomFromModule()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedOutAppState)
    }

    func testNavigateToHome_validState_changesToHomeState() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToHomeFromLoggedIn()

        XCTAssertEqual(sut.state, AppState.home)
    }

    func testNavigateToHome_invalidState_changesToDefaultLoggedOutState() {
        sut.state = AppState.login // set some other initial state in AppVM

        sut.navigateToHomeFromLoggedIn()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedOutAppState)
    }

    func testNavigateToModule_validState_changesToModuleState() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToModuleFromHome()

        XCTAssertEqual(sut.state, AppState.module)
    }

    func testNavigateToModule_invalidState_changesToDefaultLoggedOutState() {
        sut.state = AppState.login // set some other initial state in AppVM

        sut.navigateToModuleFromHome()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedOutAppState)
    }

    func testNavigateToSettings_validState_changesToSettingsState() {
        sut.signIn(withDetails: alLogInDetails)
        sut.navigateToSettingsFromHome()

        XCTAssertEqual(sut.state, AppState.settings)
    }

    func testNavigateToSettings_invalidState_changesToDefaultLoggedOutState() {
        sut.state = AppState.login // set some other initial state in AppVM

        sut.navigateToSettingsFromHome()

        XCTAssertEqual(sut.state, StateConstant.DefaultLoggedOutAppState)
    }
}
