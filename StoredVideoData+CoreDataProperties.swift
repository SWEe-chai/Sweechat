//
//  StoredVideoData+CoreDataProperties.swift
//  
//
//  Created by Hai Nguyen on 9/4/21.
//
//

import Foundation
import CoreData

extension StoredVideoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredVideoData> {
        NSFetchRequest<StoredVideoData>(entityName: "StoredVideoData")
    }

    @NSManaged public var chatRoomId: String?
    @NSManaged public var localUrl: String?

}
