
import CoreData


final class CoreDataStack: CoreDataStackProtocol {
    
    private(set)var persistentContainer: NSPersistentContainer!
    private(set) var config: CoreDataConfig!
    
    private(set) var isStoreLoaded: Bool = false
    
    init?(withConfiguration config: CoreDataConfig = CoreDataConfig()) {
        
        //Creating manager object model
        guard let mom = NSManagedObjectModel.mergedModel(from: [Bundle(for: Self.self)]) else {
            return nil
        }
        
        self.config = config
      
        //Creating persistence store description
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = config.storeType.type

        self.persistentContainer = NSPersistentContainer(name: config.storeName, managedObjectModel: mom)
    }
    
    func loadStore(_ completion: PersistentStoreLoadCompletion) {
        self.persistentContainer.loadPersistentStores { [weak self] (description, error) in
            
            self?.performSetupAfterPersistentStoreLoaded()
            completion?(description, error)
        }
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    var storeURL: String? {
        return self.persistentContainer.persistentStoreDescriptions.first?.url?.absoluteString.removingPercentEncoding
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        viewContext.perform {
            block(self.viewContext)
        }
    }
    
    //missing test case
    func performSyncTask(_ block: (NSManagedObjectContext) -> Void) {
        viewContext.performAndWait {
            block(self.viewContext)
        }
    }
    
    func clearDataBase(completion:(() ->Void)?) {
        let allEntities = persistentContainer.managedObjectModel.entities.map({ (entity) -> String in
            return entity.name ?? ""
        })
        
        self.performBackgroundTask { (context) in
            for entity in allEntities {
                if entity.count > 0 {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    do {
                        try context.execute(deleteRequest)
                    } catch let error as NSError {
                        print("Error in clean entity : \(entity)", error)
                    }
                }
            }
            completion?()
        }
    }
}

private extension CoreDataStack {
    func performSetupAfterPersistentStoreLoaded() {
        self.isStoreLoaded = true
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = self.config.mainContextMergeFromParent
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true

        self.persistentContainer.persistentStoreDescriptions = [description]
    }
}
