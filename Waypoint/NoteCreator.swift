//
//  NoteCreator.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation



struct NoteCreator{
    
    var title: String = ""
    var text: String? = nil
    var images: [String] = []
    var linkText: String? = nil
    var linkURL: String? = nil
    var AREnabled = false
    let creator: String
    var timeLeft: Int? = nil
    var latitude: Double
    var longitude: Double
    
    init(creator: String, latitude: Double, longitude: Double){
        self.creator = creator
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
    public func writeNote(){
        let noteToWrite: Note
       
            let note = Note(title: title, timeStamp: "", text: text, images: images, linkText: linkText, linkURL: linkURL, AREnabled: AREnabled, creator: creator, timeLeft: timeLeft, location: (latitude: latitude, longitude: longitude))
            noteToWrite = note
        
        //Write noteToWrite

        let uploader = DBManager()
        uploader.uploadPin(noteToWrite)
        
        
    }
}




