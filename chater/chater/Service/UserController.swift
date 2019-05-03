//
//  UserController.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserController {
    static let instance = UserController()
    
    private var appDelegate: AppDelegate?
    
    private var user: User?
    
    private var managedContext: NSManagedObjectContext?
    private var entity: NSEntityDescription?
    
    private func save() {
        guard let managedContext = self.managedContext else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Debug: UserController Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private init() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        self.appDelegate = appDelegate
        
        self.managedContext = appDelegate.persistentContainer.viewContext
        
        self.entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext!)!
        
        var userFetch: [User]?
        
        
        userFetch = try? self.managedContext?.fetch(User.fetchRequest())
        
        if userFetch == nil || userFetch?.count == 0 {
            let user = NSManagedObject(entity: entity!,
                                           insertInto: managedContext)
            
            user.setValue(nil, forKeyPath: "token")
            user.setValue(nil, forKeyPath: "userid")
            
            self.user = user as? User
            
            self.save()
            
            return
        }
        
        guard let user = userFetch?.first else {
            print("Debug: user got error")
            return
        }
        
        self.user = user
    }
    
    func clearUser() {
        userid = nil
        token = nil
    }
    
    var userid: String? {
        get {
            guard let user = self.user else {
                print("Debug: UserController Fatal error from CoreData")
                return nil
            }
            
            return user.userid
        }
        
        set {
            guard self.user != nil else {
                print("Debug: UserController Fatal error from CoreData")
                return
            }
            
            self.user?.setValue(newValue, forKey: "userid")
            
            save()
        }
    }
    
    var token: String? {
        get {
            guard let user = self.user else {
                print("Debug: UserController Fatal error from CoreData")
                return nil
            }
            
            return user.token
        }
        
        set {
            guard self.user != nil else {
                print("Debug: UserController Fatal error from CoreData")
                return
            }
            
            self.user?.setValue(newValue, forKey: "token")
            
            save()
        }
    }
}
