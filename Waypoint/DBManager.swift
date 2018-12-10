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
    
    
    
    
    func uploadPin(_ note : Note){
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
        let dataJSON = try encoder.encode(note)
        let data =  try JSONSerialization.jsonObject(with: dataJSON) as? [String : Any] ?? [:]
        let locationData = ["latitude" : note.latitude, "longitude" : note.longitude]
        let autoId = self.ref.childByAutoId().key
        self.ref.child("notes").child(autoId!).setValue(data)
        self.ref.child("locations").child(autoId!).setValue(locationData)
        }catch{
            print("error \(error)")
        }
        
    }
    
    
   
    
    
    
    
}




