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
    @IBOutlet weak var lblHighTemp: UILabel!
    @IBOutlet weak var lblLowTemp: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var outerView: UIView!
    
    var weather:WeatherEntity?
    
    var weatherViewModel = WeatherViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let weatherData = weather?.weatherData {
            self.updateOnView(weatherDataString: weatherData)
        }
    }
    
    private func setupBindings() {
        
    }
    
    func updateOnView(weatherDataString: String) {
        do {
            let weatherModel = try JSONDecoder().decode(WeatherModel.self, from: weatherDataString.data(using: .utf8) ?? Data())
            
            lblCity.text = self.weather?.cityName
            self.lblWeatherDescription.text = weatherModel.weather?.first?.main

            //Main temp
            let fahrenheit = weatherModel.main?.temp ?? 0
            let celsius = (fahrenheit - 32) * 5/9
            self.lblTemperature.text = String(Int(celsius))
            
            //High Temp
            let fahrenheitHigh = weatherModel.main?.temp_max ?? 0
            let celsiusHigh = (fahrenheitHigh - 32) * 5/9
            self.lblHighTemp.text = String(Int(celsiusHigh))
            
            //Low Temp
            let fahrenheitLow = weatherModel.main?.temp_min ?? 0
            let celsiusLow = (fahrenheitLow - 32) * 5/9
            self.lblLowTemp.text = String(Int(celsiusLow))

        }
        catch {
            debugPrint("Error in parsing weather model",error)
        }
    }
    
}
