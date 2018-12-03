//
//  DBManager.swift
//  Waypoint
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation


class DBManager  {
    
    let DBurl = "https://waypoint-62326.firebaseio.com/notes/-LSprPMglgRHmGj8m4y2.json"
    var noteData = [Note]()
    var createdNoteUpload = Note()
    var noteOnServer = Note()
    
    
    public func getNote(at index: Int) -> Note{
        if noteData.indices.contains(index) {
        return noteData[index]
        }else {
            return Note()
        }
            
    }
    
    
    func downloadPin() {
        guard let url = URL(string: DBurl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            
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
                
                
                //   self.noteData = try JSONDecoder().decode([Note].self, from: data)
                // do something w note data
                
            } catch{
                print("error \(error)")
                print("Error Serializing")
            }
            
            
            }.resume()
    }
    
    //In the works
    func fetchPinLocation(){
        
        
        
            guard let url = URL(string: DBurl) else {
                return
            }
            
            URLSession.shared.dataTask(with: url)
            
        
        
        
    }
    
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

