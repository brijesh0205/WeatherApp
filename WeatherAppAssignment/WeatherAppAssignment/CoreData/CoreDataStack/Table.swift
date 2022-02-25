
import Foundation
import CoreData

struct FetchModel {
    var predicate: NSPredicate?
    var orderby: Order<String>?
    var fetchLimit: Int?
}

enum Order<String> {
    case ascending(String)
    case descending(String)
}

class Table<Entity: NSManagedObject> {
    
    private(set) var context: NSManagedObjectContext?
    var fetchModel = FetchModel()

    internal func setContext(context: NSManagedObjectContext?) {
        self.context = context
    }
    
    internal func `where`(format: String,
                          _ args: Any...) -> Self {
        let arguments = args.map({$0}) as [Any]
        let predicate = NSPredicate(format: format, argumentArray: arguments)
        fetchModel.predicate = predicate
        return self
    }
    
    internal func orderBy(_ orderby:Order<String>) -> Self {
        fetchModel.orderby = orderby
        return self
    }
    
    internal func fetchLimit(_ limit:Int) -> Self {
        fetchModel.fetchLimit = limit
        return self
    }
}
