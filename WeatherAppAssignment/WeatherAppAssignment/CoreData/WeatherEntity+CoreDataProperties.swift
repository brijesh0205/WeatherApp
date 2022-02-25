//
//  WeatherEntity+CoreDataProperties.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 24/02/22.
//
//

import Foundation
import CoreData


extension WeatherEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherEntity> {
        return NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var currentTemperature: Int16
    @NSManaged public var weatherData: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension WeatherEntity : Identifiable {

}
