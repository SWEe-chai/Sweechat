import XCTest
@testable import Sweechat

class RegistrationViewModelIntegrationTests: XCTestCase {
    private var appViewModel: AppViewModel!
    private var sut: RegistrationViewModel!

    override func setUp() {
        super.setUp()
        appViewModel = AppViewModel()
        sut = RegistrationViewModel()
        sut.delegate = appViewModel
    }

    override func tearDown() {
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapBackButton_navigatesToEntryState() {
        sut.didTapBackButton()

        XCTAssertEqual(appViewModel.state, .entry)
    }
}
