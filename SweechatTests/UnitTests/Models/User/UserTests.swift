import XCTest
@testable import Sweechat

class UserTests: XCTestCase {
    private var details = UserRepresentation(id: "1", name: "user", profilePictureUrl: "url")
    private var sut: User!

    override func setUp() {
        super.setUp()
        sut = User(details: details)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCreateUser_returnsUserWithDummyUserDetails() {
        sut = User.createDummyUser()

        XCTAssertEqual(sut.id, User.dummyUserId)
        XCTAssertEqual(sut.name, User.dummyUserName)
        XCTAssertNil(sut.profilePictureUrl)
        XCTAssertFalse(sut.isLoggedIn)
    }

    func testSubscribeToSignedIn_callsFunctionUponChangingLoggedInStatus() {
        var isFunctionCalled = false
        let function: (Bool) -> Void = { _ in
            isFunctionCalled = true
        }
        _ = sut.subscribeToIsLoggedIn(function: function)

        sut.isLoggedIn = true

        XCTAssertTrue(isFunctionCalled)
    }

    func testUpdateUserData_allDetailsFilled_updatesUserDataWithDetails() {
        let newDetails = UserRepresentation(id: "2", name: "name", profilePictureUrl: "pic", isLoggedIn: true)

        sut.updateUserData(withDetails: newDetails)

        XCTAssertEqual(sut.id, newDetails.id)
        XCTAssertEqual(sut.name, newDetails.name)
        XCTAssertEqual(sut.profilePictureUrl, newDetails.profilePictureUrl)
        XCTAssertEqual(sut.isLoggedIn, newDetails.isLoggedIn)
    }

    func testUpdateUserData_nilProfilePictureUrl_updatesUserDataWithDetailsAndNilProfilePictureUrl() {
        let newDetails = UserRepresentation(id: "2", name: "name", profilePictureUrl: nil, isLoggedIn: true)

        sut.updateUserData(withDetails: newDetails)

        XCTAssertEqual(sut.id, newDetails.id)
        XCTAssertEqual(sut.name, newDetails.name)
        XCTAssertEqual(sut.profilePictureUrl, newDetails.profilePictureUrl)
        XCTAssertEqual(sut.isLoggedIn, newDetails.isLoggedIn)
    }
}
