
import Foundation
import CoreData

class Transaction {
    private(set) var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    internal func create<Entity:NSManagedObject>(record: Record<Entity>) -> Entity {
        let entity = record.createWith(context: context)
        return entity
    }
    
    internal func fetchAll<Entity:NSManagedObject>(from:Table<Entity>) -> Array<Entity> {
        var fetchedResults = Array<Entity>()
        do {
            let fetchRequest = Entity.fetchRequest()
            
            if let predicate = from.fetchModel.predicate {
                fetchRequest.predicate = predicate
            }
            
            if let order = from.fetchModel.orderby {
                switch order {
                case .ascending(let key):
                    let sortDescriptor = NSSortDescriptor.init(key: key, ascending: true)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                case .descending(let key):
                    let sortDescriptor = NSSortDescriptor.init(key: key, ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                }
            }
            if let fetchLimit = from.fetchModel.fetchLimit {
                fetchRequest.fetchLimit = fetchLimit
            }
            let results = (try context.fetch(fetchRequest) as? [Entity]) ?? []
            fetchedResults =  results
        } catch {
            let fetchError = CoreDataWorkerError.cannotFetch("Cannot fetch error: \(error))")
            // handle error
            debugPrint(fetchError)
        }
        return fetchedResults
    }
    
    internal func fetchOne<Entity:NSManagedObject>(from:Table<Entity>) -> Entity? {
        let all = fetchAll(from: from)
        return all.first
    }
    
    internal func deleteAll<Entity:NSManagedObject>(from:Table<Entity>) {
        do {
            let fetchRequest = Entity.fetchRequest()
            
            if let predicate = from.fetchModel.predicate {
                fetchRequest.predicate = predicate
            }
            
            if let order = from.fetchModel.orderby {
                switch order {
                case .ascending(let key):
                    let sortDescriptor = NSSortDescriptor.init(key: key, ascending: true)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                case .descending(let key):
                    let sortDescriptor = NSSortDescriptor.init(key: key, ascending: false)
                    fetchRequest.sortDescriptors = [sortDescriptor]
                }
            }
            if let fetchLimit = from.fetchModel.fetchLimit {
                fetchRequest.fetchLimit = fetchLimit
            }
            let results = (try context.fetch(fetchRequest) as? [Entity]) ?? []
            
            for result in results {
                context.delete(result)
            }
        } catch {
            let fetchError = CoreDataWorkerError.cannotFetch("Cannot fetch error: \(error))")
            // handle error
            debugPrint(fetchError)
        }
    }
}
