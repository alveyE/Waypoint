//
//  CreatePasswordViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/17/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class CreatePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField! {
        didSet{
            passwordField.delegate = self
        }
    }
    public var firstName = ""
    public var lastName = ""
    public var emailCreated = ""
    public var usernameCreated = ""
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        errorLabel.isHidden = true

        checkPassword()
        
        
        
    }


    @IBAction func nextPressed(_ sender: Any) {
    guard let password = passwordField.text else {return}
    checkPassword()

    if errorLabel.isHidden {
         //Go to
        let enterBirthday = self.storyboard!.instantiateViewController(withIdentifier: "enterBirthday") as! BirthdaySelectorViewController
                    enterBirthday.emailCreated = emailCreated
                    enterBirthday.usernameCreated = usernameCreated
                    enterBirthday.firstName = firstName
                    enterBirthday.lastName = lastName
                    enterBirthday.passwordCreated = password
                   enterBirthday.modalPresentationStyle = .fullScreen
                   present(enterBirthday, animated: true)
        print("ACCOUNT INFO\n\(emailCreated)\n\(usernameCreated)\n\(password)")
    }
    
    }
    
    
    private func checkPassword(){
        let password = passwordField.text ?? ""
        if password.count < 8 {
            errorLabel.text = "Password must be at least 8 characters"
            errorLabel.isHidden = false
        }else{
            errorLabel.isHidden = true
        }
    }

}
