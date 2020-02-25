//
//  CreateUsernameViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/20/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class CreateUsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var usernameField: UITextField! {
        didSet{
            usernameField.delegate = self
        }
    }
    public var firstName = ""
    public var lastName = ""
    public var emailCreated = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        errorLabel.isHidden = true

        checkUsername()
        
        
        
    }

    @IBAction func usernameEdited(_ sender: Any) {
        errorLabel.isHidden = true

        checkUsername()
    }
    @IBAction func nextPressed(_ sender: Any) {
        
        guard let username = usernameField.text else {return}
        checkUsername()

        if self.errorLabel.isHidden{
            let createPassword = self.storyboard!.instantiateViewController(withIdentifier: "createPassword") as! CreatePasswordViewController
            createPassword.emailCreated = emailCreated
            createPassword.usernameCreated = username
            createPassword.firstName = firstName
            createPassword.lastName = lastName
            createPassword.modalPresentationStyle = .fullScreen
            present(createPassword, animated: true)
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

}
