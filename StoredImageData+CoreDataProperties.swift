//
//  StoredImageData+CoreDataProperties.swift
//  
//
//  Created by Hai Nguyen on 9/4/21.
//
//

import Foundation
import CoreData

extension StoredImageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredImageData> {
        NSFetchRequest<StoredImageData>(entityName: "StoredImageData")
    }

    @NSManaged public var chatRoomId: String?
    @NSManaged public var data: Data?
    @NSManaged public var size: Int64
    @NSManaged public var url: String?

}
