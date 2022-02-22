//
//  LoginViewModel.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 21/02/22.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    
    public enum LoginError {
        case serverMessage(String)
    }
    
    public enum LoginResponse {
        case serverMessage(String)
    }
    
    public let hideLoader: PublishSubject<Bool> = PublishSubject()
    public let success: PublishSubject<Void> = PublishSubject()
    public let error : PublishSubject<LoginError> = PublishSubject()
    
    private let disposable = DisposeBag()
    
    var xmpp:XMPPHelper?
    
    func connectXMPP(userName:String, password:String) {
        self.hideLoader.onNext(false)
        do {
            try self.xmpp = XMPPHelper(userJIDString: userName,
                                                      password: password)
            self.xmpp?.connect(completionHandler: { success, error in
                self.hideLoader.onNext(true)
                if success {
                    self.success.onNext(())
                }
                else {
                    self.error.onNext(.serverMessage(error?.localizedDescription ?? ""))
                }
            })
        }
        catch {
            self.hideLoader.onNext(true)
            self.error.onNext(.serverMessage("Failed to connect server."))
        }
    }
}
