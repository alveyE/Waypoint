//
//  Note.swift
//  Bulletin
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation

public struct Note {
    
    var text: String?
    var images: [String]
    var link: (text: String?, url: String)?
    var AREnabled = false
    let creator: User
    var timeLeft: Int?
    let location: (latitude: Double, longitude: Double)
    
    
    
    enum Catagory{
        case info, emergency, safety, helpful
    }

    init(text: String?,images: [String],link: (text: String?, url: String)?,AREnabled: Bool,creator: User, timeLeft: Int, location: (latitude: Double, longitude: Double)){
        self.text = text
        self.images = images
        self.link = link
        self.AREnabled = AREnabled
        self.creator = creator
        self.timeLeft = timeLeft
        self.location = location
    }
    
    init(){
        text = nil
        images = []
        link = nil
        creator = User(username: "",password: "",id: 0)
        timeLeft = nil
        location = (0,0)
    }
    
    
    
    
}
