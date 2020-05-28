//
//  CreateGroupViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/28/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateGroupViewController: UIViewController {

    
    @IBOutlet weak var privateSwitch: UISwitch!
    
    @IBOutlet weak var groupNameField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        
    }
    
    private func checkGroupName(){
        let bannedGroupNames = ["waypoint","fractyldev","nigger","usernames","$","@","#","%","*","(",")",";","\"","?","/","\\",":"]
                
                 
                 let groupName = groupNameField.text ?? ""
                 
                 if groupName.count > 20 {
                     self.errorLabel.text = "Group Name must not be more than 20 characters"
                     self.errorLabel.isHidden = false
                 }
                 
                 let ref = Database.database().reference()
                 ref.child("groups").observeSingleEvent(of: .value, with: { (snapshot) in
                     var takenNames = [String]()
                     for case let childSnapshot as DataSnapshot in snapshot.children {
                         //                let key = childSnapshot.key
                         if let childData = childSnapshot.value as? [String : Any] {
                             
                             let usernameRetrieved = childData["group name"] as? String ?? ""
                             takenNames.append(usernameRetrieved.lowercased())
                             
                             
                         }
                     }
                     
                     if takenNames.contains(groupName.lowercased()) {
                         //Do error
                         self.errorLabel.text = "Group name taken"
                         self.errorLabel.isHidden = false
                     }
                    if self.errorLabel.isHidden {
                        self.createGroup()
                    }
                 })
                 if groupName == ""{
                     self.errorLabel.text = "Enter a group name"
                     self.errorLabel.isHidden = false
                 }
                 for word in bannedGroupNames {
                     if groupName.lowercased().contains(word){
                         self.errorLabel.text = "Invalid group name"
                         self.errorLabel.isHidden = false
                     }
                 }
                 if groupName.containsEmoji {
                     self.errorLabel.text = "Invalid group name"
                     self.errorLabel.isHidden = false
                 }
    }
    

    @IBAction func createPressed(_ sender: Any) {
        errorLabel.isHidden = true
        checkGroupName()
    }
    
    private func createGroup(){
        
        let groupName = groupNameField.text ?? ""
        let privateGroup = privateSwitch.isOn
        
        if let user = Auth.auth().currentUser {
            
            let ref = Database.database().reference()
            let uid = user.uid
            
            let groupInfo: [String:Any] = [
                "name" : groupName,
                "creator" : uid,
                "members" : [uid],
                "private" : privateGroup
            ]
            
            
            let autoId = ref.childByAutoId().key!
            ref.child("groups").child(autoId).setValue(groupInfo)
            ref.child("groups").child("groupNames").childByAutoId().setValue(["name" : groupName])

            ref.child("users").child(uid).child("groups").childByAutoId().setValue(["groupID" : autoId])
            
            
        }else{
            errorLabel.text = "Error creating group"
            errorLabel.isHidden = false
        }
        
        
        
        
    }
    
}
