
import Foundation
import CoreData

class Record<Entity: NSManagedObject> {
    init() {}
    internal func createWith(context: NSManagedObjectContext) -> Entity {
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Entity.self), into: context) as! Entity
        return newEntity
    }
}
