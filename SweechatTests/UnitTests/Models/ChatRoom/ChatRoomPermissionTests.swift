import XCTest
@testable import Sweechat

class ChatRoomPermissionTests: XCTestCase {
    func testCanRead_withReadPermission_returnsTrue() {
        XCTAssertTrue(ChatRoomPermission.canRead(permission: ChatRoomPermission.read))
    }

    func testCanRead_withoutReadPermission_returnsFalse() {
        XCTAssertFalse(ChatRoomPermission.canRead(permission: ChatRoomPermission.none))
    }

    func testCanWrite_withWritePermission_returnsTrue() {
        XCTAssertTrue(ChatRoomPermission.canWrite(permission: ChatRoomPermission.write))
    }

    func testCanWrite_withoutWritePermission_returnsFalse() {
        XCTAssertFalse(ChatRoomPermission.canWrite(permission: ChatRoomPermission.none))
    }
}
