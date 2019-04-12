//
//  Note.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation

public struct Note : Codable{
    
    var widgets = ["title"]
    
    var title: String
    var timeStamp: String
    var text: [String]?
    var images: [[String:String]]?
    var links: [String]?
    var drawings: [String]?
    let creator: String
    let latitude: Double
    let longitude: Double
    
    
    
    
    enum Catagory{
        case info, emergency, safety, helpful
    }
    
    init(widgets: [String], title: String, timeStamp: String, text: [String]?,images: [[String:String]]?,  links: [String]?, drawings: [String]?, creator: String, location: (latitude: Double, longitude: Double)){
        self.widgets = widgets
        self.title = title
        self.text = text
        self.images = images
        self.links = links
        self.drawings = drawings
        self.creator = creator
        latitude = location.latitude
        longitude = location.longitude
        
        if timeStamp ==  "" {
        let utcDate = Date()
            
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyyMMddHHmmss"
        let utcTimeZoneStr = formatter.string(from: utcDate)

        self.timeStamp = utcTimeZoneStr
        }else {
            self.timeStamp = timeStamp
        }
    }
    
        init(){
            title = ""
            text = nil
            images = nil
            links = nil
            creator = ""
            latitude = 0
            longitude = 0
            timeStamp = ""
    }
    
    
    
    
   
    
    
    
    
}




