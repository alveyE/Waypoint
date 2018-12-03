//
//  DBManager.swift
//  Waypoint
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation


class DBManager  {
    
    let DBurl = "http://localhost:3000/note"
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
        do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        print("DATA DATA DATA")
            let jsonData = try encoder.encode(note)
            
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
        print("DATA DATA DATA")
        }catch {
            
        }
        
        guard let url = URL(string: DBurl) else {
            print("URL EROOR URL ER")
        return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            
            //check err
            
            guard data != nil else {
                print("DATA == NIL ERROR")
                return
            }
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(note)
                
                // print(String(data: data, encoding: .utf8)!)
                print("UPLOAD UPLOAD")
                // do something w note data
                
            } catch _ {
                print("Error Serializing")
            }
            
            
            }.resume()
    }
    
    
    
}

