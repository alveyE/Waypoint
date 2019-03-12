//
//  SignUpViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/8/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var ref: DatabaseReference!
    
    @IBOutlet var mainView: UIView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            mainView.addGestureRecognizer(tap)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
    }
    @objc private func disableKeyboard(){
        mainView.endEditing(true)
    }
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        guard let username = usernameField.text else {return}
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (authresult, error) in
            if error != nil {
                print("error \(String(describing: error))")
                return
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if error != nil {
                    print("error \(String(describing: error))")
                    return
                }
                })
            
            
                //Upload user to database as well
            if let user = Auth.auth().currentUser {
             self.ref = Database.database().reference()
             self.ref.child("users").child(user.uid).setValue(["username": username])
         
            
            }
            })
        
    }
    
}
