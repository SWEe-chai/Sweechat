import Combine

class HomeViewModel: ObservableObject {
    weak var delegate: HomeDelegate?
    var user: User
    var moduleViewModels: [ModuleViewModel]
    private var subscribers: [AnyCancellable] = []
    @Published var text: String = ""

    init(user: User) {
        self.user = user
        self.text = "Welcome home \(user.name)"
        // TODO: ADD LOAD MODULES FROM FACADE
        moduleViewModels = [
            ModuleViewModel(user: user)
        ]
        initiateSubscribers()
    }

    private func initiateSubscribers() {
        let nameSubscriber = user.subscribeToName { newName in
            self.text = "Welcome home \(newName)"
        }
        subscribers.append(nameSubscriber)
    }

    func didTapModuleButton() {
        delegate?.navigateToModuleFromHome()
    }

    func didTapSettingsButton() {
        delegate?.navigateToSettingsFromHome()
    }
}
