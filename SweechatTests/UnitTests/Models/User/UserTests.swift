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

    func testUpdateUserData_allDetailsFilled_updatesUserDataWithDetails() {
        let newDetails = UserRepresentation(id: "2", name: "name", profilePictureUrl: "pic")

        sut.updateUserData(withDetails: newDetails)

        XCTAssertEqual(sut.id, newDetails.id)
        XCTAssertEqual(sut.name, newDetails.name)
        XCTAssertEqual(sut.profilePictureUrl, newDetails.profilePictureUrl)
    }

    func testUpdateUserData_nilProfilePictureUrl_updatesUserDataWithDetailsAndNilProfilePictureUrl() {
        let newDetails = UserRepresentation(id: "2", name: "name", profilePictureUrl: nil)

        sut.updateUserData(withDetails: newDetails)

        XCTAssertEqual(sut.id, newDetails.id)
        XCTAssertEqual(sut.name, newDetails.name)
        XCTAssertEqual(sut.profilePictureUrl, newDetails.profilePictureUrl)
    }
}
