import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    static func fetchItemsInChatRoom(chatRoomId: String) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "chatRoomId = %@", chatRoomId as CVarArg)

        return request
    }
}
