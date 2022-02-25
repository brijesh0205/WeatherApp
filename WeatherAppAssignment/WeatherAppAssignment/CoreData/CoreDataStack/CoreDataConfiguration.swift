
import Foundation


struct CoreDataConfig {
    
    var storeType: CoreDataStoreType = .sqlite
    var storeName: String = "WeatherApp"
    var mainContextMergeFromParent: Bool = true
}
