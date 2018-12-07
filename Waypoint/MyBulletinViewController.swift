//
//  MyBulletinViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MyBulletinViewController: UIViewController {

    private let savedNotesIDs = ["-LSzHCaUkfje9BGRsq2R","-LSzHCaWz1HoKzLTsdhJ","-LSzcPImVM_hFKngJKrB"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for save in savedNotesIDs {
            getNote(withID: save)
        }
        
        
    }
    

    private var yPosition: CGFloat = 0

    
    private func getNote(withID noteID: String){
        ref = Database.database().reference()
        
        ref.child("notes").child(noteID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : Any] {
                
                let title = value["title"] as? String
                let timeStamp = value["timeStamp"] as? String
                let text = value["text"] as? String
                let images = value["images"] as? [String]
                let linkText = value["linkText"] as? String
                let linkURL = value["linkURL"] as? String
                let AREnabled = value["AREnabled"] as? Bool
                let creator = value["creator"] as? User
                let timeLeft = value["timeLeft"] as? Int
                let latitude = value["latitude"] as? Double
                let longitude = value["longitude"] as? Double
                let loadedNote = Note(title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images ?? [], linkText: linkText, linkURL: linkURL, AREnabled: AREnabled ?? false, creator: creator ?? User(username: "", password: "", id: 0), timeLeft: timeLeft, location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
              
                let noteView = NoteView()
                
                let width: CGFloat = self.view.frame.size.width
                let height: CGFloat = self.view.frame.size.height
                noteView.frame = CGRect(x: 0, y: self.yPosition, width: width, height: height * 7/10)
                noteView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                
                noteView.editable = false
                
                
                noteView.title = loadedNote.title
                noteView.time = loadedNote.timeStamp
                
                
                if let displayText = loadedNote.text {
                    noteView.text = displayText
                }
                if let notepics = loadedNote.images{
                    for imgURL in notepics {
                        noteView.addImage(withURL: imgURL)
                    }
                }
                if let link = loadedNote.linkURL {
                    if let linkText = loadedNote.linkText {
                        noteView.addLink(text: linkText, url: link)
                    }else{
                        noteView.addLink(text: link, url: link)
                    }
                }
                
                self.scrollView.addSubview(noteView)
                self.yPosition += noteView.frame.height + height/15
                self.scrollView.contentSize.height += noteView.frame.height + height/15
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }

}
