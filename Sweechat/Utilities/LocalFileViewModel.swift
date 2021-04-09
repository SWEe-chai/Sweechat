import Combine
import Foundation

class LocalFileViewModel: ObservableObject {
    var onlineUrl: String
    weak var delegate: MediaMessageViewModelDelegate?
    @Published var state: MediaFetchState = .loading
    @Published var localUrl: URL!

    init(onlineUrl: String, delegate: MediaMessageViewModelDelegate) {
        self.onlineUrl = onlineUrl
        self.delegate = delegate
        getLocalVideoUrl()
    }

    private func getLocalVideoUrl() {
        delegate?.fetchVideoLocalUrl(fromUrl: onlineUrl) { localUrlString in
            guard let localUrlString = localUrlString else {
                self.state = .failed
                return
            }
            DispatchQueue.main.async {
                self.state = .success
                self.localUrl = URL(fileURLWithPath: localUrlString)
            }
        }
    }

    func updateOnlineUrl(newUrl: String) {
        if newUrl != onlineUrl {
            self.onlineUrl = newUrl
            getLocalVideoUrl()
        }
    }
}
