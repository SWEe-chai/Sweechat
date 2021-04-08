import Foundation
import CoreData

class Persistence {
    var context: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!

    init(_ storageType: PersistenceType) {
        self.persistentContainer = NSPersistentContainer(name: "Sweechat")

        if storageType == .inMemory {
          let description = NSPersistentStoreDescription()
          description.url = URL(fileURLWithPath: "/dev/null")
          self.persistentContainer.persistentStoreDescriptions = [description]
        }

        self.persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
