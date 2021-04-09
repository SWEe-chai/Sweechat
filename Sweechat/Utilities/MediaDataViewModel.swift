import SwiftUI
import Combine

class MediaDataViewModel: ObservableObject {
    @Published var url: String
    @Published var data = Data()
    @Published var state: MediaFetchState = .loading
    weak var delegate: MediaMessageViewModelDelegate?

    init(url: String, delegate: MediaMessageViewModelDelegate) {
        self.url = url
        self.delegate = delegate
        self.fetchData()
    }

    func fetchData() {
        delegate?.fetchImageData(fromUrl: url) { data in
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
        self.url = url
        self.state = .loading
        fetchData()
    }

}
