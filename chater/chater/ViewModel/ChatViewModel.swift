//
//  ChatViewModel.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import Foundation
import UIKit

class ChatViewModel {
    var updateHandler: ()->Void = {}
    
    var messages: [Message] = []
    
    func sendMessage(_ msg: String) {
        WSServer.instance.send(msg)
    }
    
    func startUpdate() {
        WSServer.instance.observers.append(self)
    }
    
    func getMessage(by index: Int) -> Message {
        return messages[index]
    }
    
    func estimatedLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        
        let size = CGSize(width: width, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: font]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    
    func getHeightCell(by index: Int) -> CGFloat {
        let textWidth = (messages[index].userid == (WSServer.instance.userID ?? 0) ? 135 : 160);
        
        let totalLabelHeight = estimatedLabelHeight(text: messages[index].message, width: CGFloat(textWidth), font: UIFont.systemFont(ofSize: 14))
        

        return ceil(totalLabelHeight)+17 + (messages[index].userid == (WSServer.instance.userID ?? 0) ? 0 : 15)
    }
    
    
    func getHistory() {
        Server.history { messages in
            self.messages = messages
            
            self.updateHandler()
        }
    }
}

extension ChatViewModel: MessageObesrver {
    func didReciveMessage(_ msg: Message) {
        self.messages.append(msg)
        self.updateHandler()
    }
}
