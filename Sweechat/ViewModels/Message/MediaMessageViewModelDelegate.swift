import Foundation

protocol MediaMessageViewModelDelegate: AnyObject {
    func fetchData(fromUrl url: String, onCompletion: @escaping (Data?) -> Void)
}
