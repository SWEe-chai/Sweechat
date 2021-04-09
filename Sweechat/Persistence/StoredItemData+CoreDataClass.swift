//
//  StoredItemData+CoreDataClass.swift
//  
//
//  Created by Hai Nguyen on 9/4/21.
//
//

import Foundation
import CoreData

@objc(StoredItemData)
public class StoredItemData: NSManagedObject {
    static func fetchItemsInChatRoom(chatRoomId: String, limitSize: Int) -> NSFetchRequest<StoredItemData> {
        let request: NSFetchRequest<StoredItemData> = StoredItemData.fetchRequest()
        request.predicate = NSPredicate(format: "chatRoomId = %@ AND #size < %i", chatRoomId as CVarArg, limitSize)
        return request
    }

    static func fetchItemInChatRoom(url: String, chatRoomId: String) -> NSFetchRequest<StoredItemData> {
        let request: NSFetchRequest<StoredItemData> = StoredItemData.fetchRequest()
        let chatRoomIdPredicate = NSPredicate(format: "chatRoomId = %@", chatRoomId as CVarArg)
        let urlPredicate = NSPredicate(format: "url = %@", url as CVarArg)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            chatRoomIdPredicate, urlPredicate
        ])
        return request
    }

    static func deleteAll() -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredItemData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        return deleteRequest
    }

    static func delete(url: String, from chatRoomId: String) -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredItemData")
        let chatRoomIdPredicate = NSPredicate(format: "chatRoomId = %@", chatRoomId as CVarArg)
        let urlPredicate = NSPredicate(format: "url = %@", url as CVarArg)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            chatRoomIdPredicate, urlPredicate
        ])
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        return deleteRequest
    }
}
