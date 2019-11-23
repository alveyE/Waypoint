//
//  GroupManagerViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 5/11/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GroupManagerViewController: UIViewController {

    var groupNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add a Group"
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        createElements()
        
    }
    
    @objc private func cancelPressed(){
        self.dismiss(animated: true, completion: nil)
    }

    private func createElements(){
        
        
        let createButtonWidth = view.frame.width * 19/20
        groupNameField = UITextField(frame: CGRect(x: view.frame.width / 2 - (createButtonWidth/2), y: view.frame.height/4, width: createButtonWidth, height: createButtonWidth/10));
        groupNameField.placeholder = "Enter group name"
        groupNameField.borderStyle = .roundedRect
        let createButton = UIButton(frame: CGRect(x: view.frame.width / 2 - (createButtonWidth/2), y: view.frame.height/3, width: createButtonWidth, height: createButtonWidth/8))
        createButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        createButton.setTitle("Create", for: .normal)
        let borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        createButton.addTopBorderWithColor(color: borderColor, width: 1)
        createButton.addBottomBorderWithColor(color: borderColor, width: 1)
        createButton.addLeftBorderWithColor(color: borderColor, width: 1)
        createButton.addRightBorderWithColor(color: borderColor, width: 1)
        let tap = UITapGestureRecognizer(target: self, action: #selector(createGroup))
        createButton.addGestureRecognizer(tap)
        view.addSubview(groupNameField)
        view.addSubview(createButton)
    }

    
    @objc private func createGroup(){
        //Make group GANG ACTIVITY MMM
    
        addMyNotes()
        
        
        
        
        
        
    }
    
    
    private func addMyNotes(){
        
    let ref = Database.database().reference()
        
        ref.child("notes").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    let creator = childData["createdByUid"] as? String ?? ""
                
                    if creator != "" {
                        ref.child("users").child(creator).child("notesCreated").childByAutoId().child("noteID").setValue(childSnapshot.key)
                    }
                    
                   
                    
                }
            }
           
        })
        
    }
    
    
    private func fixUsernames(){
        
        
        let ref = Database.database().reference()

        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    let username = childData["username"] as? String ?? ""
                
                    print(childSnapshot.key)
                    print(username)
                    ref.child("users").child("usernames").child(childSnapshot.key).child("username").setValue(username)
                    print("PLACED")
                   
                    
                }
            }
           
        })
        
        
        
        
    }
    
    private func testBig(){
        print("testing big kind")
        
         var testNum = 1
         
         var testNoteCreator = NoteCreator(creator: "ethanalvey", latitude: 0.0, longitude: 0.0)
         
         for _ in 0...20 {
         let lat = Double.random(in: -90 ..< 90)
         let long = Double.random(in: -180 ..< 180)
         testNoteCreator = NoteCreator(creator: "ethanalvey", latitude: lat, longitude: long)
             testNoteCreator.title = "Note \(testNum)"
         testNoteCreator.widgets = ["title","text"]
         testNoteCreator.text = ["Test #\(testNum)"]
         testNoteCreator.writeNote()
             testNum += 1
         
         }
    }
    

}


