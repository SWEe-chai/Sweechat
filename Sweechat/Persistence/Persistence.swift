import Foundation
import CoreData

class Persistence {
    var context: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    private static var persistence: Persistence!

    private init(_ storageType: PersistenceType) {
        self.persistentContainer = NSPersistentContainer(name: "Sweechat")
        self.persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        context = persistentContainer.viewContext
        context.mergePolicy = NSOverwriteMergePolicy
    }

    static func shared() -> Persistence {
        if let persistence = persistence {
            return persistence
        }
        Persistence.persistence = Persistence(.inDisk)
        return Persistence.persistence
    }
}
