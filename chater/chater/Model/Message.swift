//
//  Message.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation

class Message {
    var userid: Int
    var nickName: String
    var message: String
    var time: String = ""
    
    init(userid: Int, nickName: String, message: String, time: String) {
        self.userid = userid
        self.nickName = nickName
        self.message = message
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: time) else { return }
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        dateFormatter.dateFormat = "HH:mm"
        
        self.time = dateFormatter.string(from: Calendar.current.date(from: comp)!)
    }
}
