//
//  Note.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation

public struct Note : Codable{
    
    
    
    var title: String
    var timeStamp: String
    var text: String?
    var images: [String]?
    var linkText: String?
    var linkURL: String?
    var AREnabled = false
    let creator: User
    var timeLeft: Int?
    let latitude: Double
    let longitude: Double
    
    
    
    enum Catagory{
        case info, emergency, safety, helpful
    }
    
    init(title: String, timeStamp: String, text: String?,images: [String],linkText: String?, linkURL: String? ,AREnabled: Bool,creator: User, timeLeft: Int?, location: (latitude: Double, longitude: Double)){
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
        var hour = calendar.component(.hour, from: date)
        if hour > 12 {
            hour -= 12
        }
        let minutes = calendar.component(.minute, from: date)
        self.timeStamp = "\(month)/\(day)/\(year) \(hour):\(minutes)"
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
            creator = User(username: "",password: "",id: 0)
            timeLeft = nil
            latitude = 0
            longitude = 0
            timeStamp = ""
    }
    
    
    
    
   
    
    
    
    
}




