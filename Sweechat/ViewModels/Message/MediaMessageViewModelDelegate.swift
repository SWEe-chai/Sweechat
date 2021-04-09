import Foundation

protocol MediaMessageViewModelDelegate: AnyObject {
    func fetchImageData(fromUrl url: String, onCompletion: @escaping (Data?) -> Void)
    func fetchVideoLocalUrl(fromUrl url: String, onCompletion: @escaping (String?) -> Void)
}
