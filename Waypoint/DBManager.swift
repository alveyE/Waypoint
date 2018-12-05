//
//  DBManager.swift
//  Waypoint
//
//  Created by -Theory- on 11/27/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DBManager  {

    var ref: DatabaseReference!
   
    init(){
        ref = Database.database().reference()
    }
    
    
    
    
    func uploadPin(_ note : Note){
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do{
        let dataJSON = try encoder.encode(note)
        let data =  try JSONSerialization.jsonObject(with: dataJSON) as? [String : Any] ?? [:]
        self.ref.child("notes").childByAutoId().setValue(data)
        }catch{
            print("error \(error)")
        }
        
    }
    
    
    public func getImage(withURL url: String){
        
        let imageURL = URL(string: url)!
        
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: imageURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        // Do something with your image.
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
        
        
    }
    
    
    
}




