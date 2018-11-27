//
//  Server.swift
//  Bulletin
//
//  Created by Ethan Alvey on 11/16/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation
import UIKit

public class Server {
    public static var notes = [Note]()
   
    
    public static var amountOfNotes: Int {
        return notes.count
    }
    
//    public static var images = [String:UIImage]()
    public static var images = ["newyork":UIImage(named: "newyork.jpeg")]
    
   
    
    
}
