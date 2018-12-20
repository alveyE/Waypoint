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
    var text: String?
    var images: [String]?
    var linkText: String?
    var linkURL: String?
    var AREnabled = false
    let creator: String
    var timeLeft: Int?
    let latitude: Double
    let longitude: Double
    
    
    
    
    enum Catagory{
        case info, emergency, safety, helpful
    }
    
    init(title: String, timeStamp: String, text: String?,images: [String],linkText: String?, linkURL: String? ,AREnabled: Bool,creator: String, timeLeft: Int?, location: (latitude: Double, longitude: Double)){
        self.title = title
        self.text = text
        self.images = images
        self.linkText = linkText
        self.linkURL = linkURL
        self.AREnabled = AREnabled
        self.creator = creator
        self.timeLeft = timeLeft
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
            images = []
            linkText = nil
            linkURL = nil
            creator = ""
            timeLeft = nil
            latitude = 0
            longitude = 0
            timeStamp = ""
    }
    
    
    
    
   
    
    
    
    
}




