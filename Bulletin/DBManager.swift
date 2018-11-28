//
//  DBManager.swift
//  Bulletin
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation


class NoteContentFetcher {
    
    
    var noteData = [Note]()
    var createdNoteUpload = Note()
    
    
    init(){
        
        let DBurl = "legendtitans.org"
        
        guard let url = URL(string: DBurl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            
            //check err
            
            guard let data = data else {
                return
            }
            
            do {
                 self.noteData = try JSONDecoder().decode([Note].self, from: data)
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
    
    
    class PinLocationFetcher {
        
        init() {
            
            let DBurl = "our database url"
            
            guard let url = URL(string: DBurl) else {
                return
            }
            
            URLSession.shared.dataTask(with: url)
            
        }
        
        
    }
    
    func uploadPin(_ note : Note) {
        
        let DBurl = "our database url"
        
        guard let url = URL(string: DBurl) else {
        return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            
            //check err
            
            guard data != nil else {
                return
            }
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(note)
                print(String(data: data, encoding: .utf8)!)
                // do something w note data
                
            } catch _ {
                print("Error Serializing")
            }
            
            
            }.resume()
    }
    
    
    
}

