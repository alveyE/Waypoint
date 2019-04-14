//
//  NoteCreator.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation



struct NoteCreator{

    let uploader = DBManager()
    
    var widgets = ["title"]
    
    var title: String = ""
    var timeStamp: String = ""
    var text: [String]? = nil
    var images: [[String:String]]? = [] {
        didSet{
            if submitted {
                //Adds late image to already created note
                if let dataAdded = images?.last {
                uploader.addImageToNote(imageData: dataAdded)
                }
            }
        }
    }
    var links: [String]? = nil
    var drawings: [String]? = [] {
        didSet{
            if submitted {
                if let drawingAdded = drawings?.last {
                    uploader.addDrawingToNote(drawingURL: drawingAdded)
                }
                
            }
        }
    }
    let creator: String
    var latitude: Double
    var longitude: Double
    
    var submitted = false
    var idCreated = ""
    init(creator: String, latitude: Double, longitude: Double){
        self.creator = creator
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
    public mutating func writeNote(){
        let noteToWrite = Note(widgets: widgets, title: title, timeStamp: timeStamp, text: text, images: images, links: links, drawings: drawings, creator: creator, location: (latitude: latitude, longitude: longitude))
        
//        //Write noteToWrite

        
        uploader.uploadPin(noteToWrite)
        submitted = true
        
    }
    

}




