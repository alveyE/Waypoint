//
//  ChangePasswordViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/18/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        updatedLabel.isHidden = true
        errorLabel.isHidden = true
        usernameField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    

    @IBAction func updateUsernamePressed(_ sender: Any) {
        checkUsername()
        
        
    }
    
    private func changeUsername(){
        if errorLabel.isHidden {
                   if let user = Auth.auth().currentUser {
                       let uid = user.uid
                      
                    
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = usernameField.text
                        changeRequest?.commitChanges(completion: { (error) in
                            if error != nil {
                                print("error \(String(describing: error))")
                                return
                            }
                        })
                    ref.child("users").child(uid).child("username").setValue(usernameField.text)
                       ref.child("users").child("usernames").child(uid).child("username").setValue(usernameField.text)
                       updatedLabel.isHidden = false
                       errorLabel.isHidden = true
                        
                   }
               }
    }
    
    
   
    
    private func checkUsername(){
        errorLabel.isHidden = true

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
            self.changeUsername()
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
