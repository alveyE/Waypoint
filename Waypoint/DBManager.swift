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

class DBManager  {
    
    let DBurl = "https://waypoint-62326.firebaseio.com/notes/-LSprPMglgRHmGj8m4y2.json"
    var noteData = [Note]()
    var createdNoteUpload = Note()
    var noteOnServer = Note()
    var ref: DatabaseReference!
   
    init(){
        ref = Database.database().reference()
    }
    
    public func getNote(withID noteID: String){
                
        ref.child("notes").child(noteID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : Any] {
                
                let title = value["title"] as? String
                let timeStamp = value["timeStamp"] as? String
                let text = value["text"] as? String
                let images = value["images"] as? [String]
                let linkText = value["linkText"] as? String
                let linkURL = value["linkURL"] as? String
                let AREnabled = value["AREnabled"] as? Bool
                let creator = value["creator"] as? User
                let timeLeft = value["timeLeft"] as? Int
                let latitude = value["latitude"] as? Double
                let longitude = value["longitude"] as? Double
                let note = Note(title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images ?? [], linkText: linkText, linkURL: linkURL, AREnabled: AREnabled ?? false, creator: creator ?? User(username: "", password: "", id: 0), timeLeft: timeLeft, location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                PreservedDownloads.notes.append(note)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    func downloadPin() -> Note {
        guard let url = URL(string: DBurl) else {
            return self.noteOnServer
        }
        URLSession.shared.dataTask(with: url){ (data, response, err) in
        print("AFTEF URL")
            //check err
            if let error = err {
                print("error: \(error)")
            }
            print("DATA IS \(data)")
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                self.noteOnServer = try JSONDecoder().decode(Note.self, from: data)
                return
                print(self.noteOnServer)
                print("NOTE IS ABOVE")
                //   self.noteData = try JSONDecoder().decode([Note].self, from: data)
                // do something w note data
                
            } catch{
                print("error \(error)")
                print("Error Serializing")
            }
            
            
            }.resume()
        return self.noteOnServer

    }
    
    //In the works
    func fetchPinLocation(){
        
        
        
            guard let url = URL(string: DBurl) else {
                return
            }
            
            URLSession.shared.dataTask(with: url)
            
        
        
        
    }
    
    func upload(_ note : Note){
        
        
        
    }
    
    
    
//    func uploadPin(_ note : Note) {
//        let databaseURL = "https://waypoint-62326.firebaseio.com/notes.json"
//        guard let url = URL(string: databaseURL) else {
//            print("Error: Could not initialize URL")
//        return
//        }
//
//        do{
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                let data = try encoder.encode(note)
//                var request = URLRequest(url: url)
//                request.httpMethod = "POST"
//                request.httpBody = data
//
//
//            URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
//                if let error = error {
//                    print ("error: \(error)")
//                    return
//                }
//            }.resume()
//
//
//        }catch{
//            print("Error")
//        }
//
//    }
//
    
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
    
    
    
}

