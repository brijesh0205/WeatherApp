//
//  WeatherViewController.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 22/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblWeatherDescription: UILabel!
    var cityModel:CityModel?
    
    public var weather = PublishSubject<WeatherModel>()
    var weatherViewModel = WeatherViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let cityModel = cityModel {
            self.weatherViewModel
                .getWeatherData(cityModel: cityModel)
                .subscribe({ [weak self] response in
                    
                    guard let self = self else {
                        return
                    }
                    
                    switch response {
                        case let .next(data):
                            debugPrint(data)
                            if let weather = data as? WeatherModel {
                                
                                let fahrenheit = weather.main?.temp ?? 0
                                let celsius = (fahrenheit - 32) * 5/9
                                self.lblTemperature.text = String(celsius)
                                
                                self.lblWeatherDescription.text = weather.weather?.first?.main
                            }
                        
                        case let .error(error):
                            debugPrint(error)
                        case .completed:
                            break
                    }
                    
                    
                    
                    
                
                }).disposed(by: disposeBag)
        }
    }
    
    private func setupBindings() {
        weatherViewModel
            .weather
            .observe(on: MainScheduler.instance)
            .bind(to: weather)
            .disposed(by: disposeBag)
        
        
    }
    
}
