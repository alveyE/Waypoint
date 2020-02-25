//
//  EnterEmailViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/17/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth
class EnterEmailViewController: UIViewController, UITextFieldDelegate {

    
    public var firstName = ""
    public var lastName = ""
    
    @IBOutlet weak var invalidLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField! {
        didSet{
            emailField.delegate = self
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invalidLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        invalidLabel.isHidden = true

        checkEmail()
        
        
        
    }
    
    
    @IBAction func emailEdited(_ sender: Any) {

          checkEmailInUse()
    }
    
    @IBAction func nextTouched(_ sender: Any) {
     guard let email = emailField.text else {return}
        checkEmail()

        if invalidLabel.isHidden {
            let createUsername = self.storyboard!.instantiateViewController(withIdentifier: "createUsername") as! CreateUsernameViewController
            createUsername.emailCreated = email
            createUsername.firstName = firstName
            createUsername.lastName = lastName
            createUsername.modalPresentationStyle = .fullScreen
            present(createUsername, animated: true)

        }
    
    }
    private func checkEmail(){
        let email = emailField.text ?? ""
        if !isValidEmail(testStr: email){
            invalidLabel.text = "Enter a valid email"
            invalidLabel.isHidden = false
        }else if invalidLabel.text == "Enter a valid email"{
            invalidLabel.isHidden = true
        }
        
        
    }
    
    func checkEmailInUse(){
        let email = emailField.text ?? ""
Auth.auth().fetchSignInMethods(forEmail: email, completion: {
            (signInMethods, error) in

            if let error = error {
                print(error.localizedDescription)
            } else if let sim = signInMethods {
                for type in sim {
                    if type == "password"{
                        self.invalidLabel.text = "An account with this email already exist"
                        self.invalidLabel.isHidden = false
                    }
                }
            }
        })
    }

    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
