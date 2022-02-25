
import Foundation
import CoreData

protocol CoreDataWorkerProtocol {
    var mainContext: NSManagedObjectContext {get}
    func fetchAll<Entity:NSManagedObject>(from:Table<Entity>) -> Array<Entity>
    func fetchOne<Entity:NSManagedObject>(from:Table<Entity>) -> Entity?
    @discardableResult func deleteAll<Entity:NSManagedObject>(from:Table<Entity>) -> Bool
    func perform(async task: @escaping ((Transaction)->Void), completion:((TaskResult)->Void)?)
    func clearDataBase(completion:(() ->Void)?)
}

extension CoreDataWorkerProtocol {
    func perform(async task: @escaping ((Transaction)->Void), completion:((TaskResult)->Void)?=nil) {
        perform(async: task, completion: completion)
    }
}
