import XCTest
@testable import Sweechat

class ModulePermissionTests: XCTestCase {
    func testCanCreateForum_withCanCreateForumPermission_returnsTrue() {
        XCTAssertTrue(ModulePermission.canCreateForum(permission: ModulePermission.forumCreation))
    }

    func testCanCreateForum_withoutCanCreateForumPermission_returnsFalse() {
        XCTAssertFalse(ModulePermission.canCreateForum(permission: ModulePermission.none))
    }

    func testCanStarChatRoom_withCanStarChatRoomPermission_returnsTrue() {
        XCTAssertTrue(ModulePermission.canStarChatRoom(permission: ModulePermission.starChatRoom))
    }

    func testCanStarChatRoom_withoutCanStarChatRoomPermission_returnsFalse() {
        XCTAssertFalse(ModulePermission.canStarChatRoom(permission: ChatRoomPermission.none))
    }
}
