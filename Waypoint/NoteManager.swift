//
//  NoteManager.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation
import UIKit

struct NoteManager {
    
    private(set) var notes = [Note]()
    private(set) var noteLocations = [(latitude: Double, longitude: Double)]()
    
   
    
    
    
    init(){
        
        // Get amount of Notes from server (for now it will keep all info on device)
        for note in Server.notes {
            noteLocations.append((note.latitude, note.longitude))
        }
        Server.notes.append(Note(title: "", text: "Wow!", images: [], link: nil, AREnabled: false, creator: User(username: "", password: "", id: 0), timeLeft: nil, location: (latitude: 40, longitude: -73)))
        
    }
    
    
    public func loadNote(at index: Int) -> Note{
        let database = DBManager()
       return database.getNote(at: index)
        
       // return Server.notes[index]
    }
    
    
    public func loadImage(withURL givenURL: String) -> UIImage?{
        return Server.images[givenURL] ?? nil
    }
    
    
}
