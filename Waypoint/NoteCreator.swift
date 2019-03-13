//
//  NoteCreator.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation



struct NoteCreator{

    var widgets = ["title"]
    
    var title: String = ""
    var timeStamp: String = ""
    var text: [String]? = nil
    var images: [[String:String]]? = []
    var links: [String]? = nil
    var drawings: [String]? = nil
    let creator: String
    var latitude: Double
    var longitude: Double
    
    init(creator: String, latitude: Double, longitude: Double){
        self.creator = creator
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
    public func writeNote(){
        let noteToWrite = Note(widgets: widgets, title: title, timeStamp: timeStamp, text: text, images: images, links: links, drawings: drawings, creator: creator, location: (latitude: latitude, longitude: longitude))
        
//        //Write noteToWrite

        let uploader = DBManager()
        uploader.uploadPin(noteToWrite)
        
        
    }
}




