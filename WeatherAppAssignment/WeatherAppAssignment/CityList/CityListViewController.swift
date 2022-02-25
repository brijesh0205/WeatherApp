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
    
    @IBOutlet weak var tblCity: UITableView!
    
    public var cities = PublishSubject<[WeatherEntity]>()

    var cityViewModel = CityViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblCity.rowHeight = 90
        
        setupBindings()
        
        DispatchQueue.main.async {
            self.cityViewModel.createAndSaveCityList()
        }
    }
    
    private func setupBindings() {
        
        cityViewModel
            .cities
            .observe(on: MainScheduler.instance)
            .bind(to: cities)
            .disposed(by: disposeBag)
        
        cities.bind(to: tblCity.rx.items(cellIdentifier: "CityTableViewCell", cellType: CityTableViewCell.self)) {  (row,city,cell) in
            cell.cellCity = city
            }.disposed(by: disposeBag)
        
        tblCity.rx.modelSelected(WeatherEntity.self)
                    .subscribe(onNext: { [weak self] model in
                        debugPrint("selected Model : ", model)
                        let weatherView = self?.storyboard?.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController
                        weatherView.weather = model
                        self?.navigationController?.pushViewController(weatherView, animated: true)
                    }).disposed(by: disposeBag)
    }
}
