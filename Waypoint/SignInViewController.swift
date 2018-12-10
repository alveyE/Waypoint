//
//  SignInViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth


class SignInViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
  
    @IBOutlet var mainView: UIView!{
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            mainView.addGestureRecognizer(tap)
        }
    }
    
    
    @objc private func disableKeyboard(){
        mainView.endEditing(true)
    }
    @IBOutlet weak var incorrectLabel: UILabel!
    
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        incorrectLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    
  
    @IBAction func signinButtonPressed(_ sender: UIButton) {
        
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.incorrectLabel.isHidden = false
            }
            if user != nil {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
}
