//
//  WSServer.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation
import Starscream

class WSServer {
    static var instance = WSServer()
    
    private var socket: WebSocket?
    var token: String? {
        didSet {
            UserController.instance.token = self.token
        }
    }
    var userID: Int? {
        didSet {
            UserController.instance.userid = String(describing: self.userID!)
        }
    }
    
    var observers: [MessageObesrver] = []
    
    private var ready: Bool = false
    
    private func isReady() -> Bool {
        return socket != nil && token != nil && ready
    }
    
    private init() {}
    
    func connect() {
        guard let token = self.token else { return }
        
        let authString: String = token
        let base64String = authString.data(using: String.Encoding.utf8)!.base64EncodedString()
        
        var request = URLRequest(url: URL(string: "ws://chater.kostyakulakov.ru/chat")!)
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        //Initiate websocket
        socket = WebSocket(request: request)
        socket?.advancedDelegate = self
        socket?.connect()
    }
    
    func send(_ msg: String) {
        guard isReady(), let socket = self.socket else { return }
        
        socket.write(string: msg)
    }
}

extension WSServer: WebSocketAdvancedDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("Debug: websocket is connected")
        self.ready = true
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        print("Debug: websocket is disconnected: \(error?.localizedDescription)")
        self.ready = false
        socket.connect()
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        print("Debug: got some text: \(text)")
        
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            guard let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
            
            
            guard let userid = (jsonObj["userid"] as? String) else { return }
            guard let msg = (jsonObj["msg"] as? String) else { return }
            guard let nickname = (jsonObj["user"] as? String) else { return }
            guard let sdate = (jsonObj["time"] as? String) else { return }
            
            self.reciveMessage(userid: userid, nickname: nickname, msg: msg, time: sdate)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        print("Debug: got some data: \(data.count)")
    }
    
    func websocketHttpUpgrade(socket: WebSocket, request: String) {
        print("Debug: websocketHttpUpgrade")
    }
    
    func websocketHttpUpgrade(socket: WebSocket, response: String) {
        print("Debug: websocketHttpUpgrade response")
    }
}

protocol MessageObesrver {
    func didReciveMessage(_ msg: Message)
}

protocol MessageObservable {
    func reciveMessage(userid: String, nickname: String, msg: String, time: String)
}

extension WSServer: MessageObservable {
    func reciveMessage(userid: String, nickname: String, msg: String, time: String) {
        let message = Message(userid: Int(userid)!, nickName: nickname, message: msg, time: time)
        
        for observer in self.observers {
            observer.didReciveMessage(message)
        }
    }
}
