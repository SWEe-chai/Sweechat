import Foundation
import CoreData

@objc(StoredImageData)
public class StoredImageData: NSManagedObject {
    static func fetchItemsInChatRoom(chatRoomId: String, limitSize: Int) -> NSFetchRequest<StoredImageData> {
        let request: NSFetchRequest<StoredImageData> = StoredImageData.fetchRequest()
        request.predicate = NSPredicate(format: "chatRoomId = %@ AND #size < %i", chatRoomId as CVarArg, limitSize)
        return request
    }

    static func fetchItemInChatRoom(urlString: String, chatRoomId: String) -> NSFetchRequest<StoredImageData> {
        let request: NSFetchRequest<StoredImageData> = StoredImageData.fetchRequest()
        let chatRoomIdPredicate = NSPredicate(format: "chatRoomId = %@", chatRoomId as CVarArg)
        let urlPredicate = NSPredicate(format: "urlString = %@", urlString as CVarArg)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            chatRoomIdPredicate, urlPredicate
        ])
        return request
    }

    static func deleteAll() -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredImageData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        return deleteRequest
    }

    static func delete(urlString: String, from chatRoomId: String) -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredImageData")
        let chatRoomIdPredicate = NSPredicate(format: "chatRoomId = %@", chatRoomId as CVarArg)
        let urlPredicate = NSPredicate(format: "urlString = %@", urlString as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            chatRoomIdPredicate, urlPredicate
        ])
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        return deleteRequest
    }
}
