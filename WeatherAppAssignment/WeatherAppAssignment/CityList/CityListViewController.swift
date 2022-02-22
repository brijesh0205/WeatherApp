//
//  CityListViewController.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 22/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class CityListViewController: UIViewController {

    public var cities = PublishSubject<[CityModel]>()
    @IBOutlet weak var tblCity: UITableView!
    
    var cityViewModel = CityViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
        DispatchQueue.main.async {
            self.cityViewModel.createCityListArray()
        }
    }
    
    private func setupBindings() {
        cityViewModel
            .cities
            .observe(on: MainScheduler.instance)
            .bind(to: cities)
            .disposed(by: disposeBag)
        
        
        //Cell Update
        cities.bind(to: tblCity.rx.items(cellIdentifier: "CityCell", cellType: UITableViewCell.self)) { (row,city,cell) in

            cell.textLabel?.text = city.cityName
            
        }.disposed(by: disposeBag)
        
        
        //Row Selection
        /*tblCity.rx.itemSelected
          .subscribe(onNext: { [weak self] indexPath in
            
              debugPrint("itemSelected : ", indexPath)
              let weatherView = self?.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
              weatherView.cityModel = self?.cities[indexPath.row]
              self?.navigationController?.pushViewController(weatherView, animated: true)
              
          }).disposed(by: disposeBag)
         */
        
        tblCity.rx.modelSelected(CityModel.self)
                    .subscribe(onNext: { [weak self] model in
                        debugPrint("selected Model : ", model)
                        let weatherView = self?.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
                        weatherView.cityModel = model
                        self?.navigationController?.pushViewController(weatherView, animated: true)
                    }).disposed(by: disposeBag)
    }
}
