import Foundation

protocol MediaMessageViewModelDelegate: AnyObject {
    func fetchImageData(fromUrlString urlString: String,
                        onCompletion: @escaping (Data?) -> Void)
    func fetchLocalUrl(fromUrlString urlString: String,
                       onCompletion: @escaping (URL?) -> Void)
}
