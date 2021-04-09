import Foundation
import CoreData

@objc(StoredVideoData)
public class StoredVideoData: NSManagedObject {
    static func delete(url: String, from chatRoomId: String) -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredVideoData")
        let chatRoomIdPredicate = NSPredicate(format: "chatRoomId = %@", chatRoomId as CVarArg)
        let urlPredicate = NSPredicate(format: "localUrl = %@", url as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            chatRoomIdPredicate, urlPredicate
        ])
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        return deleteRequest
    }
}
