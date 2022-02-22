//
//  LoginViewController.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 16/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, Alert {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var loginViewModel = LoginViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.txtUsername.text = "brijesh"
        self.txtPassword.text = "123456"
        
        setupBindings() 
    }
    
    private func setupBindings() {
        loginViewModel
            .hideLoader.bind(to: indicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        loginViewModel
            .success
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.displayAlert(with: "Alert", message: "Login success.", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            })
            .disposed(by: disposeBag)
        
        
        loginViewModel
            .error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (success) in
//                self.displayAlert(with: "Alert", message: "Login failed.", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
                
                let cityView = self?.storyboard?.instantiateViewController(withIdentifier: "CityListViewController") as! CityListViewController
                self?.navigationController?.pushViewController(cityView, animated: true)
                
            })
            .disposed(by: disposeBag)

    }

    @IBAction func tapLogin(_ sender: Any) {
        
        guard let username = self.txtUsername.text, username.count > 0 else {
            self.displayAlert(with: "Alert", message: "Please enter username.", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            return
        }
        
        guard let password = self.txtPassword.text, password.count > 0 else {
            self.displayAlert(with: "Alert", message: "Please enter password.", actions: [UIAlertAction(title: "OK", style: .default, handler: nil)])
            return
        }
        
        loginViewModel.connectXMPP(userName: username, password: password)
    }
}

