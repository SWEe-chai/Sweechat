import SwiftUI
import Combine

class ImageDataViewModel: ObservableObject {
    @Published var urlString: String
    @Published var data = Data()
    @Published var state: MediaFetchState = .loading
    weak var delegate: MediaMessageViewModelDelegate?

    init(urlString: String, delegate: MediaMessageViewModelDelegate) {
        self.urlString = urlString
        self.delegate = delegate
        self.fetchData()
    }

    func fetchData() {
        delegate?.fetchImageData(fromUrlString: urlString) { data in
            DispatchQueue.main.async {
                guard let data = data, !data.isEmpty else {
                    self.state = .failed
                    return
                }
                self.data = data
                self.state = .success
            }
        }
    }

    func updateUrl(url: String) {
        if url == self.urlString {
            return
        }
        self.urlString = url
        self.state = .loading
        fetchData()
    }

}
