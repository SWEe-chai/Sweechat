import XCTest
@testable import Sweechat

class DataToStringTests: XCTestCase {
    private var sut: Data!

    override func setUp() {
        super.setUp()
        sut = Data("Test".utf8)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testToData_returnsDataRepresentation() {
        XCTAssertEqual(sut.toString(), String(decoding: sut, as: UTF8.self))
    }
}
