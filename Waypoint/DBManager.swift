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

class DBManager  {

    var ref: DatabaseReference!
    let storage = Storage.storage()
    init(){
        ref = Database.database().reference()
    }
    
    
    
    
    func uploadPin(_ note : Note){
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
        let dataJSON = try encoder.encode(note)
        let data =  try JSONSerialization.jsonObject(with: dataJSON) as? [String : Any] ?? [:]
        self.ref.child("notes").childByAutoId().setValue(data)
        }catch{
            print("error \(error)")
        }
        
    }
    
    
   
    func uploadImage(){
       //  let storageRef = storage.reference()
        
    }
    
    
    
}




