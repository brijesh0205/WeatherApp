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
    
    public let cities : PublishSubject<[CityModel]> = PublishSubject()

    func createCityListArray() {
        let cityJson = """
                            [
                              {
                                "cityName": "Delhi",
                                "latitude": 28.7041,
                                "longitude": 77.1025
                              },
                              {
                                "cityName": "Mumbai",
                                "latitude": 19.0760,
                                "longitude": 72.8777
                              }
                            ]
                        """
        
        do {
            let cityModelArray = try JSONDecoder().decode([CityModel].self, from: cityJson.data(using: .utf8) ?? Data())
            self.cities.onNext(cityModelArray)
        }
        catch {
            debugPrint("Error in parsing city model: ",error)
        }
    }

}
