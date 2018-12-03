//
//  DBManager.swift
//  Waypoint
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation


class DBManager  {
    
    let DBurl = "https://waypoint-62326.firebaseio.com/notes/.json"
    var noteData = [Note]()
    var createdNoteUpload = Note()
    var noteOnServer = Note()
    
    init(){
        
        
        guard let url = URL(string: DBurl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            
            //check err
            
            guard let data = data else {
                return
            }
            
            do {
                self.noteOnServer = try JSONDecoder().decode(Note.self, from: data)
                
                
              //   self.noteData = try JSONDecoder().decode([Note].self, from: data)
                // do something w note data
                
            } catch _ {
                print("Error Serializing")
            }
            
            
            }.resume()
        
    }
    
    public func getNote(at index: Int) -> Note{
        if noteData.indices.contains(index) {
        return noteData[index]
        }else {
            return Note()
        }
            
    }
    
    
    func PinLocationFetcher() {
        
            
            
    }
    
    //In the works
    func fetchPinLocation(){
        
        
        
            guard let url = URL(string: DBurl) else {
                return
            }
            
            URLSession.shared.dataTask(with: url)
            
        
        
        
    }
    //fugure out how to send to the server
    //Must keep variable name as "note" this is how server api identifies the object and allows for optionals
    func uploadPin(_ note : Note) {
        let databaseURL = "https://waypoint-62326.firebaseio.com/notes.json"
        guard let url = URL(string: databaseURL) else {
            print("Error: Could not initialize URL")
        return
        }
        
        do{
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(note)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = data
            
            
            URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    return
                }
            }.resume()
            
            
        }catch{
            print("Error")
        }
        
    }
    
    
    
    
}

