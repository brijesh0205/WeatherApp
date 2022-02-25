//
//  CityTableViewCell.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 24/02/22.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCityName: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
        
    public var cellCity : WeatherEntity! {
        didSet {
            self.lblCityName.text = cellCity.cityName
            if cellCity.currentTemperature == 0 {
                self.lblTemp.text = "-"
            }
            else {
                self.lblTemp.text = String(cellCity.currentTemperature)
            }
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
