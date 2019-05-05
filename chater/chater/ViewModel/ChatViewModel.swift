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
    
    func widthText(_ str: String, _ font: UIFont) -> CGSize {
        let fontAttribute = [NSAttributedString.Key.font: font]
        let size = str.size(withAttributes: fontAttribute)
        return size;
    }
    
    let insideConstraintWidth = 45
    let outsideConstrainWidth = 39
    
    let insideConstraintHeight = 16
    let outsideConstrainHeight = 30
    
    let textSize: CGFloat = 14
    
    func getWidthtCell(by index: Int) -> CGFloat {
        let isInternalMessage = (messages[index].userid == (WSServer.instance.userID ?? 0))

        let text = messages[index].message
        let analyzeText = text.count < messages[index].nickName.count ? messages[index].nickName : text
        
        var width = self.widthText(analyzeText, UIFont.systemFont(ofSize: textSize)).width
        
        
        if width > 210 {
            width = 210
        }
        
        return ceil(width) + CGFloat(isInternalMessage ? insideConstraintWidth : outsideConstrainWidth)
    }
    
    func getHeightCell(by index: Int) -> CGFloat {
        let isInternalMessage = (messages[index].userid == (WSServer.instance.userID ?? 0))
        
        let textWidth = self.getWidthtCell(by: index) - CGFloat(isInternalMessage ? insideConstraintWidth : outsideConstrainWidth)
        
        let totalLabelHeight = estimatedLabelHeight(text: messages[index].message, width: CGFloat(textWidth), font: UIFont.systemFont(ofSize: textSize))
        

        return ceil(totalLabelHeight) + CGFloat(isInternalMessage ? insideConstraintHeight : outsideConstrainHeight)
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
