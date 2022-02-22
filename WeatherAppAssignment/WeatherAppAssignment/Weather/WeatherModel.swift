//
//  WeatherModel.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 22/02/22.
//

import Foundation

struct WeatherModel: Codable {
    var base : String?
    var clouds : Cloud?
    var cod : Int?
    var coord : Coordinate?
    var dt : Int?
    var id : Int?
    var main : MainWeather?
    var name : String?
    var sys : Sys?
    var timezone : Int?
    var visibility : Int?
    var weather : [Weather]?
    var wind : Wind?
}

struct MainWeather: Codable{

    var feelsLike : Float?
    var humidity : Int?
    var pressure : Int?
    var temp : Float?
    var tempMax : Float?
    var tempMin : Float?
}

struct Wind: Codable {
    var deg : Int?
    var speed : Float?
}

struct Weather: Codable{

    var descriptionField : String?
    var icon : String?
    var id : Int?
    var main : String?
    
    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case icon = "icon"
        case id = "id"
        case main = "main"
    }
}

struct Sys: Codable{
    
    var country : String?
    var id : Int?
    var sunrise : Int?
    var sunset : Int?
    var type : Int?
}

struct Coordinate: Codable{

    var lat : Float?
    var lon : Float?

}

struct Cloud : Codable{
    
    var all : Int?
    
}
