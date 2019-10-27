//
//  SecurityViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 10/25/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SecurityViewController: UIViewController {

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func deleteAccount(){
     
        if let user = Auth.auth().currentUser {
        let uid = user.uid
        user.delete { error in
            if let _ = error {
                // An error happened.
                
            } else {
                // Account deleted
                self.ref.child("users").child(uid).removeValue()
                self.ref.child("users").child("usernames").child(uid).removeValue()
                
            }
            }
        }else{
            //Not logged in
            
        }
        
        
        
    }
    
    
}
