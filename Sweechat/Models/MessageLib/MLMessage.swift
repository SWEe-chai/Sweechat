import Foundation

protocol MLMessage {
    var sender: MLSender { get set }
    var id: UUID? { get }
    var sentDate: Date { get }
    var type: MLMessageType { get set }
}
