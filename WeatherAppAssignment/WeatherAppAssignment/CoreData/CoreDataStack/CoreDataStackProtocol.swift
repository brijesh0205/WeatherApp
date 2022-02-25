
import CoreData

typealias PersistentStoreLoadCompletion = (((NSPersistentStoreDescription?, Error?) -> Void)?)

enum CoreDataStoreType: String {
    case sqlite , binary, memory
    
    var type: String {
        switch self {
        case .sqlite:
            return NSSQLiteStoreType
        case .binary:
            return NSBinaryStoreType
        case .memory:
            return NSInMemoryStoreType
        }
    }
}


protocol CoreDataStackProtocol {
    
    init?(withConfiguration config: CoreDataConfig)

    var config: CoreDataConfig! { get }
    var isStoreLoaded: Bool { get }
    var persistentContainer: NSPersistentContainer! {get}
    var viewContext: NSManagedObjectContext {get}
    var backgroundContext: NSManagedObjectContext {get}
    var storeURL: String? {get}
    func loadStore(_ completion: PersistentStoreLoadCompletion)
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
    func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
    func performSyncTask(_ block: (NSManagedObjectContext)->Void)
    func clearDataBase(completion:(() ->Void)?)
}
