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
        self.fetchDataFromUrl()
    }

    func fetchDataFromUrl() {
        if let data = delegate?.fetchData(fromUrl: url) {
            self.data = data
            self.state = .success
            return
        }
        guard let parsedURL = URL(string: url) else {
            state = .failed
            return
        }
        URLSession.shared.dataTask(with: parsedURL) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data, !data.isEmpty {
                        self.data = data
                        self.state = .success
                } else {
                    self.state = .failed
                }
            }
        }.resume()
    }

    func updateUrl(url: String) {
        self.url = url
        self.state = .loading
        fetchDataFromUrl()
    }

}
