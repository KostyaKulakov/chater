//
//  LoginViewModel.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    func auth(email: String, password: String, handler: @escaping (Bool)->Void) {
        DispatchQueue(label: "auth_thread").async {
            Server.auth(email: email, password: password) { (success) in
                DispatchQueue.main.async {
                    handler(success)
                }
            }
        }
    }
}
