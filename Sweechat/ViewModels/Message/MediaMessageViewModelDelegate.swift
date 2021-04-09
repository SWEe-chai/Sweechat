import Foundation

protocol MediaMessageViewModelDelegate: AnyObject {
    func fetchData(fromUrl url: String, onCompletion: @escaping (Data?) -> Void)
    func fetchLocalUrl(fromUrl url: String, onCompletion: @escaping (String?) -> Void)
}
