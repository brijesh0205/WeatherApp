//
//  Alert.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 16/02/22.
//


import Foundation
import UIKit

protocol Alert {
    func displayAlert(with title: String, message: String, actions: [UIAlertAction]?)
}

extension Alert where Self: UIViewController {
    func displayAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
}
