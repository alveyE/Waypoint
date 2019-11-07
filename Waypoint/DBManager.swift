//
//  DBManager.swift
//  Waypoint
//
//  Created by Carson Cramer on 11/27/18.
//  Copyright © 2018 Fractyl Development LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import UIKit

class DBManager  {

    var ref: DatabaseReference!
    
    
    init(){
        ref = Database.database().reference()
    }
    
    public var createdID = ""
    public var preWrittenID = ""
    
    
    func uploadPin(_ note : Note){
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
        let dataJSON = try encoder.encode(note)
        let data =  try JSONSerialization.jsonObject(with: dataJSON) as? [String : Any] ?? [:]
        let locationData = ["latitude" : note.latitude, "longitude" : note.longitude]
        let autoId = self.ref.childByAutoId().key
        self.createdID = autoId ?? ""
            if let currentUser = Auth.auth().currentUser {
            if preWrittenID == "" {
                self.ref.child("notes").child(autoId!).setValue(data)
                self.ref.child("notes").child(autoId!).child("createdByUid").setValue(currentUser.uid)
                self.ref.child("locations").child(autoId!).setValue(locationData)
                self.ref.child("locations").child(autoId!).child("createdByUid").setValue(currentUser.uid)
            }else {
                self.ref.child("notes").child(preWrittenID).setValue(data)
                let utcDate = Date()
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                formatter.dateFormat = "yyyyMMddHHmmss"
                let editedTime = formatter.string(from: utcDate)
                self.ref.child("notes").child(preWrittenID).child("editedTimeStamp").setValue(editedTime)
            }
            }
        }catch{
            print("error \(error)")
        }
        
    }
    
    
    func addImageToNote(imageData: [String:String]){
        ref = Database.database().reference()
        if createdID != "" {
        ref.child("notes").child(createdID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : Any] {
                var images = value["images"] as? [[String:String]] ?? []
                images.append(imageData)

                self.addImageData(images: images)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        }
    }
    
    func addDrawingToNote(drawingURL: String){
        ref = Database.database().reference()
        if createdID != "" {
            ref.child("notes").child(createdID).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                if let value = snapshot.value as? [String : Any] {
                    var drawings = value["drawings"] as? [String] ?? []
                    drawings.append(drawingURL)
                    self.addDrawingLink(drawings: drawings)
                    
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
   
    
    private func addImageData(images: [[String:String]]){
        ref.child("notes").child(self.createdID).child("images").setValue(images)
    }
    
    private func addDrawingLink(drawings: [String]){
        ref.child("notes").child(self.createdID).child("drawings").setValue(drawings)
    }
    
    
}





