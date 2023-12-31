//
//  SignInViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
  
    @IBOutlet var mainView: UIView!{
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
    @IBOutlet weak var incorrectLabel: UILabel!
    
    @IBOutlet weak var signinButton: UIButton!
    
   
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        incorrectLabel.isHidden = true
        emailField.delegate = self
        signinButton.addSubview(indicator)
        // Do any additional setup after loading the view.
    }
    
     func textFieldDidBeginEditing(_ textField: UITextField) {
        incorrectLabel.isHidden = true
    }
  
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func login(userEmail: String, userPassword: String){
        
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            self.signinButton.setImage(nil, for: .normal)
            self.indicator.isHidden = true
            self.signinButton.setTitle("Sign In", for: .normal)
            if error != nil {
                self.incorrectLabel.isHidden = false
            }
            if user != nil  {
                    
                if !(Auth.auth().currentUser?.isEmailVerified ?? false) {
                    let alert = UIAlertController(title: "Verify Email", message: "To sign in please verify your email. Please check your email for a verification email and click the link.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
                        Auth.auth().currentUser?.sendEmailVerification(completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                
                self.navigationController?.popViewController(animated: true)
                    
                if self.tabBarController == nil {
//                let tabStart = self.storyboard!.instantiateViewController(withIdentifier: "startTab")
//                self.show(tabStart, sender: self)
//                self.view = nil
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
                }
                }
                
            }else{
                self.incorrectLabel.isHidden = false
            }
        }
        
        
    }
    
    
   
    
    
    @IBAction func signinButtonPressed(_ sender: UIButton) {
        
        guard let email = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        
        
        signinButton.setTitle(nil, for: .normal)
        indicator.isHidden = false
        
        
        if isValidEmail(testStr: email){
            login(userEmail: email, userPassword: password)
        }else{
            
            var attemptedLogin = false
            
            Auth.auth().signInAnonymously() { (authResult, error) in
                if error != nil {
                    print(error.debugDescription)
                }else{

                    let ref = Database.database().reference()
                    ref.child("users").child("usernames").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        for case let childSnapshot as DataSnapshot in snapshot.children {
                            
                            if let childData = childSnapshot.value as? [String : Any] {
                                
                                let username = childData["username"] as? String ?? ""
                                
                                if email == username {
                                    attemptedLogin = true
                                    let idRetrieved = childSnapshot.key
                                    ref.child("users").child(idRetrieved).observeSingleEvent(of: .value, with: { (usersnap) in
                                        if let value = usersnap.value as? [String : Any] {
                                            let emailRetrieved = value["email"] as? String ?? ""
                                            print("Going to login with \(emailRetrieved) and \(password)")
                                            if let anon = Auth.auth().currentUser {
                                                anon.delete(completion: nil)
                                            }
                                            self.login(userEmail: emailRetrieved, userPassword: password)
                                            return
                                            
                                        }
                                    })
                                    
                                    
                                }
                                
                            }
                        }
                        if !attemptedLogin {
                        self.login(userEmail: email, userPassword: password)
                        }
                    })

                }
            }
            
            
            
        }
                
    }
    
}
