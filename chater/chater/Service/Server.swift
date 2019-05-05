//
//  Server.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation
import Alamofire

class Server {
    static var instance = Server()
    
    private init() {}
    
    static func auth(email: String, password: String, completionHandler: @escaping (Bool)->Void) {
        let params: [String: String] = ["email": email,
                                        "hash": PasswordHelper.getHash(password: password)]
        
        AF.request(serverUrl+"auth/", method: .post, parameters: params).responseJSON {
            response in
            
            guard let data = response.data else {
                completionHandler(false)
                return
            }
            
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            guard let jsonResult = jsonObj as? Dictionary<String, AnyObject> else {
                completionHandler(false)
                return
            }
            
            guard let responseCode = (jsonResult["code"] as? Int) else {
                completionHandler(false)
                return
            }
            
            guard responseCode == 200 else {
                completionHandler(false)
                return
            }
            
            guard let token = (jsonResult["token"] as? String) else {
                completionHandler(false)
                return
            }
            
            guard let id = (jsonResult["id"] as? String) else {
                completionHandler(false)
                return
            }
            
            WSServer.instance.userID = Int(id)!
            WSServer.instance.token = token
            completionHandler(true)
        }
    }
    
    static func history(succsessHandler: @escaping ([Message])->Void) {
        
        print("Debug: history join!")
        AF.request(serverUrl+"history/", method: .post).responseJSON {
            response in
            
            guard let data = response.data else { return }
            
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            
            print("Debug: history got result!")
            
            guard let jsonResult = jsonObj as? [Dictionary<String, AnyObject>] else { return }
            
            print("Debug: history ok!")
            
            var messages: [Message] = []
            
            for message in jsonResult {
                guard let userid = (message["userid"] as? String) else { continue }
                guard let msg = (message["msg"] as? String) else { continue }
                guard let nickname = (message["nickname"] as? String) else { continue }
                guard let sdate = (message["date"] as? String) else { continue }
    
                
                messages.append(Message(userid: Int(userid)!, nickName: nickname, message: msg, time: sdate))
            }
            
            succsessHandler(messages)
        }
    }
    
    private static var serverUrl = "https://chater.kkapp.ru/api/v1/"
}
