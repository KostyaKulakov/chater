//
//  LoginViewController.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var incorrectLogin: UILabel!
    
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var loginTextFieldsStackView: UIStackView!
    
    var standardElementColor: UIColor?
    
    var viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.alpha = 0
        self.loginTextFieldsStackView.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showControlElements()
        }
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showControlElements() {
        UIView.animate(withDuration: 1.5, animations: {
            self.loginButton.alpha = 1
            self.loginTextFieldsStackView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func joinButton(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        sender.isEnabled = false
        
        startAnimate()
        
        if self.standardElementColor == nil {
            self.standardElementColor = emailTextField.underLineColor
        }
        
        if self.emailTextField.underLineColor != self.standardElementColor {
            UIView.animate(withDuration: 0.5, animations: {
                self.incorrectLogin.alpha = 0
                self.emailTextField.underLineColor = self.standardElementColor!
                self.passwordTextField.underLineColor = self.standardElementColor!
                
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.incorrectLogin.isHidden = true
            })
        }
        
        viewModel.auth(email: email, password: password) {
            succsess in
            self.stopAnimate()
            DispatchQueue.main.async {
                sender.isEnabled = true
                
                if succsess {
                    self.performSegue(withIdentifier: "segueToChat", sender: self)
                } else {
                    self.incorrectLogin.alpha = 0
                    self.incorrectLogin.isHidden = false
                    
                    UIView.animate(withDuration: 1.5, animations: {
                        self.incorrectLogin.alpha = 1
                        self.emailTextField.underLineColor = self.incorrectLogin.textColor
                        self.passwordTextField.underLineColor = self.incorrectLogin.textColor
                        
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func startAnimate() {
        let pulseAnimation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.5
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        logoImage.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    func stopAnimate() {
        self.logoImage.layer.removeAnimation(forKey: "animateOpacity")
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
}
