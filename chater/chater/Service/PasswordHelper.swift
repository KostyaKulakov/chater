//
//  PasswordHelper.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation
import BCryptSwift

class PasswordHelper {
    static func getHash(password: String) -> String {
        return BCryptSwift.hashPassword(password, withSalt: "$2a$10$IvScqPK4JM.O3ONmr1t6m.") ?? ""
    }
}
