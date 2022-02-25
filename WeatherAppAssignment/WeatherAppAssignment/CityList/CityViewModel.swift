//
//  CityViewModel.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 22/02/22.
//

import Foundation
import RxSwift
import RxCocoa

class CityViewModel {
    
//    public let cities : PublishSubject<[WeatherEntity]> = PublishSubject()
    var cities = BehaviorRelay<[WeatherEntity]>(value: [])

    var coreDataWorker: CoreDataWorkerProtocol!
    
    let disposeBag = DisposeBag()

    init() {
        self.coreDataWorker = CoreDataWorker()
    }
    
    let cityJson = """
                        [
                          {
                            "cityName": "Delhi",
                            "latitude": 28.7041,
                            "longitude": 77.1025,
                            "currentTemperature" : 0
                          },
                          {
                            "cityName": "Mumbai",
                            "latitude": 19.0760,
                            "longitude": 72.8777,
                            "currentTemperature" : 0
                          },
                          {
                            "cityName": "Kolkata",
                            "latitude": 22.5726,
                            "longitude": 88.3639,
                            "currentTemperature" : 0
                          },
                          {
                            "cityName": "Chennai",
                            "latitude": 13.0827,
                            "longitude": 80.2707,
                            "currentTemperature" : 0
                          },
                          {
                            "cityName": "Gujarat",
                            "latitude": 22.2587,
                            "longitude": 71.1924,
                            "currentTemperature" : 0
                          }
                        ]
                    """

    func createAndSaveCityList() {
        
        do {
            let cityJsonArray = try JSONSerialization.jsonObject(with: cityJson.data(using: .utf8) ?? Data(), options: .fragmentsAllowed) as? [[String: Any]] ?? [[:]]
            updateCityInDB(cityWeather: cityJsonArray) { success in
                if success {
                    let savedCityArray = self.coreDataWorker?.fetchAll(from: Table<WeatherEntity>()) ?? []
                    self.cities.accept(savedCityArray)
                    self.getWeatherData(arrayCity: savedCityArray)
                }
            }

        }
        catch {
            debugPrint("Error in parsing city json: ",error)
        }
    }
    
    func updateCityInDB(cityWeather: [[String: Any]], completion:((Bool) -> Void)?) {
        coreDataWorker.perform { [weak self](transaction) in
            let context = transaction.context
            
            guard let self = self else { return }
            
            for city in cityWeather {
                
                let cityName = city["cityName"] as? String ?? ""
                let latitude = city["latitude"] as? Double ?? 0.0
                let longitude = city["longitude"] as? Double ?? 0.0
                let currentTemperature = city["currentTemperature"] as? Int16 ?? 0

                let result = self.coreDataWorker?.fetchAll(from: Table<WeatherEntity>().where(format: "%K==%@", "cityName",cityName)).first
                
                //If Record not inserted, then "result" will be nil, so will insert the data
                if result == nil {
                    let weather = WeatherEntity.init(entity: WeatherEntity.entity(), insertInto: context)
                    weather.cityName = cityName
                    weather.latitude = latitude
                    weather.longitude = longitude
                    weather.currentTemperature = currentTemperature

                    context.insert(weather)
                }
            }
        } completion: { (result) in
            switch result {
            case .success:
                debugPrint("City data saved!!")
                completion?(true)
                
            case .failure(let error):
                debugPrint("Error in saving City data : ",error)
                completion?(false)
            }
            
        }
    }
    
    func getWeatherData( arrayCity : [WeatherEntity]) {
        
        for city in arrayCity {
            let cityObject = city
            self.callAPIToGetWeatherData(weatherEntity: cityObject)
        }
    }
    
    func callAPIToGetWeatherData(weatherEntity: WeatherEntity){
        
        let param:[String:Any] = [
            "lat" : String(weatherEntity.latitude),
            "lon" : String(weatherEntity.longitude),
            "appid": WEATHER_API_KEY
        ]

        APIManager.shared.requestAPI(responseModel: WeatherModel.self, endpoint: .weather, httpMethod: .get, params: param) {[weak self] response in
            switch response {
            case .success(let weather):
                debugPrint(weather)
                
                guard let self = self else { return }
                
                do {
                    let encodedData = try JSONEncoder().encode(weather)
                    let string = String.init(data: encodedData, encoding: .utf8)

                    let update = self.cities.value
                    if let index = update.firstIndex(where: {$0.cityName ?? "" == weatherEntity.cityName ?? ""}) {
                        update[index].currentTemperature = Int16(weather.main?.temp ?? 0)
                        update[index].weatherData = string
                    }
                    self.cities.accept(update)
                    try? self.coreDataWorker.mainContext.save()
                }
                catch {
                    debugPrint("Error endecode :",error)
                }
                
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
}
