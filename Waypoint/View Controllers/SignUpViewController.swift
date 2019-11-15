//
//  SignUpViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/8/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var termsAndPrivacyBox: UIButton!
    @IBOutlet weak var ageVerificationBox: UIButton!
    @IBOutlet weak var termsAndPrivacyText: UITextView!
        
    @IBOutlet weak var ageVerificationText: UITextView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(ageVerificationPressed(_:)))
            ageVerificationText.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var errorLabel: UILabel!
    var ref: DatabaseReference!
    
    private var errorFound = false
    private var termsAndPrivacyChecked = false
    private var ageVerificationChecked = false
    
    @IBOutlet var mainView: UIView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            mainView.addGestureRecognizer(tap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        usernameField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        passwordField.delegate = self
        emailField.delegate = self
        errorLabel.isHidden = true
        setLinks()
    }
    
    private func setLinks(){
        let termsAttributedText = NSMutableAttributedString(string: termsAndPrivacyText.text)
        let _ = termsAttributedText.setAsLink(textToFind: "terms of use", linkURL: "https://fractyldev.com/waypoint/terms")
        let _ = termsAttributedText.setAsLink(textToFind: "privacy policy", linkURL: "https://fractyldev.com/waypoint/privacy")
        termsAndPrivacyText.attributedText = NSAttributedString(attributedString: termsAttributedText)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
    }
    
    
     func textFieldDidEndEditing(_ textField: UITextField) {
        errorLabel.isHidden = true

        
        if textField == usernameField {
        checkUsername()
        }else if textField == emailField {
        checkEmail()
        }else if textField == passwordField {
        checkPassword()
        }
        
        
    }
    
    private func checkUsername(){
        let bannedUsernameWords = ["waypoint","fractyldev","nigger","usernames"," ","$","@","#","%","*","(",")",";","\"","?","/","\\",":"]
       
        
        let username = usernameField.text ?? ""
        
        if username.count > 20 {
            self.errorLabel.text = "Username must not be more than 20 characters"
            self.errorLabel.isHidden = false
        }
        
        let ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            var takenNames = [String]()
            for case let childSnapshot as DataSnapshot in snapshot.children {
                //                let key = childSnapshot.key
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    let usernameRetrieved = childData["username"] as? String ?? ""
                    takenNames.append(usernameRetrieved.lowercased())
                    
                    
                }
            }
            
            if takenNames.contains(username.lowercased()) {
                //Do error
                self.errorLabel.text = "Username taken"
                self.errorLabel.isHidden = false
            }
        })
        if username == ""{
            self.errorLabel.text = "Enter a username"
            self.errorLabel.isHidden = false
        }
        for word in bannedUsernameWords {
            if username.lowercased().contains(word){
                self.errorLabel.text = "Invalid username"
                self.errorLabel.isHidden = false
            }
        }
        if username.containsEmoji {
            self.errorLabel.text = "Invalid username"
            self.errorLabel.isHidden = false
        }
    }
    
    
    private func checkEmail(){
        let email = emailField.text ?? ""
        if !isValidEmail(testStr: email){
            errorLabel.text = "Enter a valid email address"
            errorLabel.isHidden = false
        }
    }
    
    
    private func checkPassword(){
        let password = passwordField.text ?? ""
        if password.count < 8 {
            errorLabel.text = "Password must be at least 8 characters"
            errorLabel.isHidden = false
        }
    }
   
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    @IBAction func termsAndPrivacyPressed(_ sender: UIButton) {
        termsAndPrivacyChecked = !termsAndPrivacyChecked
        if termsAndPrivacyChecked {
            termsAndPrivacyBox.setImage(UIImage(named: "filledCheck"), for: .normal)
        }else{
            termsAndPrivacyBox.setImage(UIImage(named: "emptyCheck"), for: .normal)
        }
    }
    
    @IBAction func ageVerificationPressed(_ sender: UIButton) {
        ageVerificationChecked = !ageVerificationChecked
        if ageVerificationChecked {
        ageVerificationBox.setImage(UIImage(named: "filledCheck"), for: .normal)
        }else{
        ageVerificationBox.setImage(UIImage(named: "emptyCheck"), for: .normal)
        }
    }
    
    @objc private func disableKeyboard(){
        mainView.endEditing(true)
    }
    
    @IBOutlet weak var signupButton: UIButton!
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        
        guard let username = usernameField.text else {return}
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        print(ageVerificationChecked)
        print(termsAndPrivacyChecked)
                
        if !ageVerificationChecked {
            errorLabel.text = "Must be over 13 to use Waypoint"
            errorLabel.isHidden = false
        }else if errorLabel.text == "Must be over 13 to use Waypoint"{
            errorLabel.isHidden = true
        }
        
        if !termsAndPrivacyChecked{
            errorLabel.text = "Must accept the terms of use and privacy policy"
            errorLabel.isHidden = false
        }else if errorLabel.text == "Must accept the terms of use and privacy policy"{
            errorLabel.isHidden = true
        }
        
        checkUsername()
        checkEmail()
        checkPassword()
             if self.errorLabel.isHidden{
                Auth.auth().createUser(withEmail: email, password: password, completion: { (authresult, error) in
                    if String(describing: error).contains("ERROR_EMAIL_ALREADY_IN_USE") {
                        
                        self.errorLabel.text = "An account with this email already exist"
                        self.errorLabel.isHidden = false
                    
                    }else if error != nil {
                        self.errorLabel.text = "Error creating account"
                        self.errorLabel.isHidden = false
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
                        user.sendEmailVerification(completion: nil)
                        let alert = UIAlertController(title: "Verify Email", message: "Thank you for creating an account. To sign in please check your email for a verification email and click the link.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Continue to sign in", style: .default, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        self.ref = Database.database().reference()
                        self.ref.child("users").child(user.uid).setValue(["username": username, "email" : email])
                        self.ref.child("users").child("usernames").child(user.uid).setValue(["username" : username])
                        
                        //Start at map
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                        appDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
//
                    }
                })
                
            
            }
        
        
        
        
        
    }
    
}


extension String {

    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F1E6...0x1F1FF, // Regional country flags
                 0xE0020...0xE007F, // Tags
                 0xFE00...0xFE0F, // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F018...0x1F270, // Various asian characters
                 0x238C...0x2454, // Misc items
                 0x20D0...0x20FF: // Combining Diacritical Marks for Symbols
                return true
            default:
                continue
            }
        }
        return false
    }

}
