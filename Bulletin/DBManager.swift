//
//  DBManager.swift
//  Bulletin
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation

struct DBNoteData : Decodable {
    var noteID : Int
    var noteLatitude : Double
    var noteLongitude : Double
    var noteContent : String
    var noteCreationDate : String
    var noteCreationTime : String
}

class DecodeData {
    
    init(){
        
        let DBurl = "our database url"
        
        guard let url = URL(string: DBurl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url){ (data, response, err) in
            
            //check err
            
            guard let data = data else {
                return
            }
            
            do {
                let noteData = try JSONDecoder().decode([DBNoteData].self, from: data)
                // do something w note data
                
            } catch _ {
                print("Error Serializing")
            }
            
            
            }.resume()
        
    }
}

