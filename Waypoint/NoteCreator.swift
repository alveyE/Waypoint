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
    let creator: User
    var timeLeft: Int? = nil
    let latitude: Double
    let longitude: Double
    
    init(creator: User, latitude: Double, longitude: Double){
        self.creator = creator
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
//    
//    public func writeNote(){
//        let noteToWrite: Note
//        if let noteLinkURL = linkURL {
//            let note = Note(title: title, timeStamp: "", text: text, images: images, linkText: "", AREnabled: AREnabled, creator: creator, timeLeft: timeLeft, location: (latitude: latitude, longitude: longitude))
//            noteToWrite = note
//        }else{
//            let note = Note(title: title, timeStamp: "", text: text, images: images, link: nil, AREnabled: AREnabled, creator: creator, timeLeft: timeLeft, location: (latitude: latitude, longitude: longitude))
//            noteToWrite = note
//        }
//        //Write noteToWrite
//        Server.notes.append(noteToWrite)
//        
//    }
}




