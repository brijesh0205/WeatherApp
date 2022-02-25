
import CoreData


typealias CoreDataWorkerErrorCompletion = ((Error?) -> Void)?

enum CoreDataWorkerError: Error {
    case cannotFetch(String)
    case cannotSave(Error)
}

enum TaskResult {
    case success
    case failure(Error)
}

final class CoreDataWorker: CoreDataWorkerProtocol {
    
    var coreDataStack: CoreDataStackProtocol!
    
    var mainContext: NSManagedObjectContext {
        return coreDataStack.viewContext
    }
    
    init(withCoreDataStack stack: CoreDataStackProtocol = CoreDataStack()!) {
        
        self.coreDataStack = stack
        self.coreDataStack?.loadStore { (description, _) in
            if let description = description {
                print("store loading description url", description.url?.absoluteString.removingPercentEncoding ?? "")
            }
        }
    }

    func fetchAll<Entity:NSManagedObject>(from:Table<Entity>) -> Array<Entity> {
        var fetchedResults = Array<Entity>()
        coreDataStack?.performSyncTask { (context) in
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
        }
        return fetchedResults
    }
    
    func fetchOne<Entity:NSManagedObject>(from:Table<Entity>) -> Entity? {
        let all = fetchAll(from: from)
        return all.first
    }
    
    @discardableResult
    func deleteAll<Entity:NSManagedObject>(from:Table<Entity>) -> Bool {
        var isSuccess = true
        coreDataStack?.performSyncTask { (context) in
            do {
                let results = self.fetchAll(from: from)
                
                //******** Deleting Objects ************
                for result in results {
                    context.delete(result)
                }
                
                try context.save()
                
                isSuccess = true
                
            } catch {
                isSuccess = false
                let fetchError = CoreDataWorkerError.cannotFetch("Cannot fetch error: \(error))")
                // handle error
                debugPrint(fetchError)
            }
        }
        
        return isSuccess
    }
    
    func clearDataBase(completion:(() ->Void)?) {
        coreDataStack.clearDataBase(completion: completion)
    }
    
    func perform(async task: @escaping ((Transaction)->Void), completion:((TaskResult)->Void)?=nil) {
        coreDataStack?.performBackgroundTask({ (context) in
            let transaction = Transaction.init(context: context)
            task(transaction)
            do {
                try context.save()
                completion?(TaskResult.success)
            }
            catch {
                completion?(TaskResult.failure(error))
            }
        })
    }
    
    func perform(async task: @escaping ((NSManagedObjectContext)->Void), completion:((TaskResult)->Void)?=nil) {
        coreDataStack?.performBackgroundTask({ (context) in
            task(context)
            do {
                try context.save()
                completion?(TaskResult.success)
            }
            catch {
                completion?(TaskResult.failure(error))
            }
        })
    }
}
