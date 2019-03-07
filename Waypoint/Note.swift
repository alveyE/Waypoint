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
   // var images: [String]?
    var images: [[String:String]]?
    var links: [String]?
    let creator: String
    let latitude: Double
    let longitude: Double
    
    
    
    
    enum Catagory{
        case info, emergency, safety, helpful
    }
    
    init(widgets: [String], title: String, timeStamp: String, text: [String]?,images: [[String:String]]?,  links: [String]?, creator: String, location: (latitude: Double, longitude: Double)){
        self.widgets = widgets
        self.title = title
        self.text = text
        self.images = images
        self.links = links
        self.creator = creator
        latitude = location.latitude
        longitude = location.longitude
        
        if timeStamp ==  "" {
        let date = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let seconds = calendar.component(.second, from: date)
        let minutes = calendar.component(.minute, from: date)
        self.timeStamp = String(format: "%04d%02d%02d%02d%02d%02d", year,month,day,hour,minutes,seconds)
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




