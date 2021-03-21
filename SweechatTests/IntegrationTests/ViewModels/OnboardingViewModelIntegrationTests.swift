import XCTest
@testable import Sweechat

class OnboardingViewModelIntegrationTests: XCTestCase {
    private var appViewModel: AppViewModel!
    private var sut: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        appViewModel = AppViewModel()
        sut = OnboardingViewModel()
        sut.delegate = appViewModel
    }

    override func tearDown() {
        appViewModel = nil
        sut = nil
        super.tearDown()
    }

    func testDidTapEntryButton_navigatesToEntryState() {
        sut.didTapEntryButton()

        XCTAssertEqual(appViewModel.state, .entry)
    }
}
