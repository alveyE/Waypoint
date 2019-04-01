//
//  DBManager.swift
//  Waypoint
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIKit

class DBManager  {

    var ref: DatabaseReference!
    
    
    init(){
        ref = Database.database().reference()
    }
    
    public var createdID = ""
    
    func uploadPin(_ note : Note){
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
        let dataJSON = try encoder.encode(note)
        let data =  try JSONSerialization.jsonObject(with: dataJSON) as? [String : Any] ?? [:]
        let locationData = ["latitude" : note.latitude, "longitude" : note.longitude]
        let autoId = self.ref.childByAutoId().key
        self.createdID = autoId ?? ""
        self.ref.child("notes").child(autoId!).setValue(data)
        self.ref.child("locations").child(autoId!).setValue(locationData)
        }catch{
            print("error \(error)")
        }
        
    }
    
    
    func addImageToNote(id: String, imageData: [String:String]){
        ref = Database.database().reference()
        if createdID != "" {
        ref.child("notes").child(createdID).child("images").observeSingleEvent(of: .value, with: { (snapshot) in
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
   
    
    func addImageData(images: [[String:String]]){
        ref.child("notes").child(self.createdID).child("images").setValue(images)
    }
    
    
}





