import Combine
import Foundation

class LocalFileViewModel: ObservableObject {
    var onlineUrlString: String
    weak var delegate: MediaMessageViewModelDelegate?
    @Published var state: MediaFetchState = .loading
    @Published var localUrl: URL!

    init(onlineUrlString: String, delegate: MediaMessageViewModelDelegate) {
        self.onlineUrlString = onlineUrlString
        self.delegate = delegate
        getLocalUrl()
    }

    private func getLocalUrl() {
        delegate?.fetchVideoLocalUrl(fromUrlString: onlineUrlString) { localUrl in
            guard let localUrl = localUrl else {
                self.state = .failed
                return
            }
            DispatchQueue.main.async {
                self.state = .success
                self.localUrl = localUrl
            }
        }
    }

    func updateOnlineUrl(newUrl: String) {
        if newUrl != onlineUrlString {
            self.onlineUrlString = newUrl
            getLocalUrl()
        }
    }
}
