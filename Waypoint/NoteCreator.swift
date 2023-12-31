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
            if cancelImage != -1 {
                images?.remove(at: cancelImage)
                cancelImage = -1
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
            if cancelDrawing != -1 {
                drawings?.remove(at: cancelDrawing)
                cancelDrawing = -1
            }
        }
    }
    var creator: String
    var latitude: Double
    var longitude: Double
    
    var submitted = false
    var cancelImage = -1
    var cancelDrawing = -1
    var idCreated = ""
    init(creator: String, latitude: Double, longitude: Double){
        self.creator = creator
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    
    public mutating func writeNote(){
        let noteToWrite = Note(widgets: widgets, title: title, timeStamp: timeStamp, text: text, images: images, links: links, drawings: drawings, creator: creator, location: (latitude: latitude, longitude: longitude))

        
        uploader.uploadPin(noteToWrite)
        submitted = true
        
    }
    
    public mutating func writeNote(to id: String){
        let noteToWrite = Note(widgets: widgets, title: title, timeStamp: timeStamp, text: text, images: images, links: links, drawings: drawings, creator: creator, location: (latitude: latitude, longitude: longitude))
        
        uploader.preWrittenID = id
        uploader.uploadPin(noteToWrite)
        submitted = true
        
    }
    
}




