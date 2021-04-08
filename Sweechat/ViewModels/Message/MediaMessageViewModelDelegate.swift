import Foundation

protocol MediaMessageViewModelDelegate: AnyObject {
    func fetchData(fromUrl: String) -> Data?
}
