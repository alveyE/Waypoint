//
//  User.swift
//  Bulletin
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation


struct  User : Codable{
    
    var username: String
    var password: String
    var id: Int
    var savedNotes = [Note]()
    
    init(username: String, password: String, id: Int){
        self.username = username
        self.password = password
        self.id = id
    }
    
}
