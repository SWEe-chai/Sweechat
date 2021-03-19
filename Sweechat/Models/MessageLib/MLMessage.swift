import Foundation

protocol MLMessage {
    var sender: MLUser { get set }
    var id: String { get }
    var creationTime: Date { get }
    var type: MLMessageType { get set }
}
