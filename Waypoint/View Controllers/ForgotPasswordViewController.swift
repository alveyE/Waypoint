//
//  ForgotPasswordViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 4/25/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth


class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var sendResetButton: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.isHidden = true
    }
    

    @IBAction func sendResetPressed(_ sender: UIButton) {
        let email = emailField.text ?? ""
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                self.messageLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                self.messageLabel.text = "No account with that email"
                self.messageLabel.isHidden = false
            }else {
                self.messageLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.messageLabel.text = "Password reset email sent"
                self.messageLabel.isHidden = false
            }
        }
        
    }
    

}
