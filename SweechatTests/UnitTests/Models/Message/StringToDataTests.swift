import XCTest
@testable import Sweechat

class StringToDataTests: XCTestCase {
    private var sut: String!

    override func setUp() {
        super.setUp()
        sut = "Test"
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testToData_returnsDataRepresentation() {
        XCTAssertEqual(sut.toData(), Data(sut.utf8))
    }
}
