//
//  WeatherViewModel.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 22/02/22.
//

import Foundation
import RxSwift
import RxCocoa

class WeatherViewModel {
    
    public var weather = PublishSubject<WeatherModel>()
    
    func getWeatherData(cityModel: CityModel) -> Observable<Any> {
        
        return Observable.create { (observer) -> Disposable in
            
            let param:[String:Any] = [
                "lat" : String(cityModel.latitude),
                "lon" : String(cityModel.longitude),
                "appid": WEATHER_API_KEY
            ]
            
            APIManager.shared.requestAPI(responseModel: WeatherModel.self, endpoint: .weather, httpMethod: .get, params: param) { response in
                switch response {
                case .success(let response):
                    debugPrint(response)
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    debugPrint(error)
                    if let error = error.error {
                        observer.onError(error)
                    }
                    else {
                        observer.onError(NSError.init(domain: "Could not get response", code: 0, userInfo: nil) as Error)
                    }
                }
            }
            
            return Disposables.create()
        }
        
    }
}
