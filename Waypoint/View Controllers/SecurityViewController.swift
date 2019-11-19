//
//  SecurityViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 10/25/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SecurityViewController: UIViewController {

    var ref = Database.database().reference()
    
    @IBOutlet weak var displayNameLabel: UILabel!
   
    @IBOutlet weak var emailLabel: UILabel!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayUserInfo()
    }
    
   
    @IBAction func deleteTouched(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure you want to permanently delete your Waypoint Communication account?", message: "This is irreversible and you will no longer be able to interact with notes around you.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { action in
            self.deleteAccount()
        }))
        self.present(alert, animated: true, completion: nil)
    }
 
    
    
    private func displayUserInfo(){
        displayNameLabel.adjustsFontSizeToFitWidth = true
        emailLabel.adjustsFontSizeToFitWidth = true
        if let user = Auth.auth().currentUser {
            displayNameLabel.text = user.displayName
            emailLabel.text = user.email
        }else{
            displayNameLabel.text = ""
            emailLabel.text = ""
        }

        

    }
    
    private func deleteAccount(){

        if let user = Auth.auth().currentUser {

            
        let uid = user.uid

        user.delete { error in
            if let _ = error {
                // An error happened.
                print(error.debugDescription)
            } else {
                // Account deleted
               print("delete happened")
                self.ref.child("users").child(uid).removeValue { (err, ref) in
                    print(err.debugDescription)
                }
                self.ref.child("users").child("usernames").child(uid).removeValue { (err, ref) in
                    print(err.debugDescription)
                }
                
                //Return to sign in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "signinNavigation")
            }
            }
        }else{
            //Not logged in
            
        }
        
        
        
    }
    
    
}
