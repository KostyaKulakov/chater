//
//  IntroAnimationViewController.swift
//  chater
//
//  Created by Konstantin Kulakov on 02/05/2019.
//  Copyright © 2019 Konstantin Kulakov. All rights reserved.
//

import UIKit

class IntroAnimationViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var textImage: UIImageView!
    @IBOutlet weak var yPositionConstrain: NSLayoutConstraint!
    @IBOutlet weak var stackLogo: UIStackView!
    @IBOutlet weak var topStackConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.yPositionConstrain.isActive = false
            self.animatePostionToTop()
        }
        
        print("Debug: \(PasswordHelper.getHash(password: "test"))")
    }
    
    func animatePostionToTop() {
        self.textImage.alpha = 0
        
        UIView.animate(withDuration: 1.5, delay: 0.0, options: [], animations: {
            self.topStackConstrain.constant = 78
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            self.performSegue(withIdentifier: "segueToLoginScreen", sender: self)
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.textImage.isHidden = false
            self.textImage.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
}
