import Foundation

protocol MediaMessageViewModelDelegate: AnyObject {
    func fetchImageData(fromUrlString urlString: String,
                        onCompletion: @escaping (Data?) -> Void)
    func fetchVideoLocalUrl(fromUrlString urlString: String,
                            onCompletion: @escaping (URL?) -> Void)
}
