//
//  ChatViewController.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var msgTextField: LoginTextField!
    @IBOutlet weak var chatTableView: UITableView!
    
    var viewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WSServer.instance.connect()

        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        self.chatTableView.register(UINib.init(nibName: "InsideMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "InsideMessageTableViewCell")
        
        self.chatTableView.register(UINib.init(nibName: "OutsideMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "OutsideMessageTableViewCell")
        
        self.chatTableView.separatorStyle = .none;
        self.chatTableView.allowsSelection = false
        
        viewModel.updateHandler = self.updateHandler
        
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        
        viewModel.getHistory()
        viewModel.startUpdate()
    }
    @IBAction func sendMsg(_ sender: Any) {
        guard let msg = self.msgTextField.text else { return }
        
        viewModel.sendMessage(msg)
        self.msgTextField.text = nil
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        print(keyboardFrame.size.height)
        
        self.scrollView.contentInset.bottom = keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func updateHandler() {
        self.chatTableView.reloadData()
        self.chatTableView.layoutIfNeeded()
        self.chatTableView.scrollToRow(at: IndexPath(item: self.viewModel.messages.count-1, section: 0), at: .bottom, animated: true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var message = viewModel.getMessage(by: indexPath.row)

        
        if message.userid == (WSServer.instance.userID ?? 0) {
            guard let cell = self.chatTableView.dequeueReusableCell(withIdentifier: "InsideMessageTableViewCell") as? InsideMessageTableViewCell else { fatalError("Can't create cell") }
            
            cell.message.text = message.message
            cell.time.text = message.time
            
            cell.viewHeight.constant = viewModel.getHeightCell(by: indexPath.row)
            
            return cell
        } else {
            guard let cell = self.chatTableView.dequeueReusableCell(withIdentifier: "OutsideMessageTableViewCell") as? OutsideMessageTableViewCell else { fatalError("Can't create cell") }
            
            cell.message.text = message.message
            cell.name.text = message.nickName
            cell.time.text = message.time
            
            cell.viewHeight.constant = viewModel.getHeightCell(by: indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getHeightCell(by: indexPath.row) + 16
    }
    
}
