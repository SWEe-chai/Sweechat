import Combine
import XCTest
@testable import Sweechat

class ModuleListTests: XCTestCase {
    private var sut: ModuleList!

    override func setUp() {
        super.setUp()
        sut = ModuleList.of(User(id: Identifier<User>(stringLiteral: "1")))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSubscribeToModules_callsFunctionOnModulesChange() {
        var isFunctionCalled = false
        let function: ([Module]) -> Void = { _ in
            isFunctionCalled = true
        }

        let _: AnyCancellable = sut.subscribeToModules(function: function)
        sut.modules = []

        XCTAssertTrue(isFunctionCalled)
    }
}
