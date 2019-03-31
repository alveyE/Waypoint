////
////  NoteLayoutViewController.swift
////  Waypoint
////
////  Created by Bret Alvey on 12/19/18.
////  Copyright © 2018 Ethan Alvey. All rights reserved.
////
//
//import UIKit
////import FirebaseDatabase
//
//class NoteLayoutViewController: UIViewController, UITextViewDelegate {
//
//    var ref: DatabaseReference!
//    var note:UINoteView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let tt = UIImage(named: "tower.JPG")
//        print(tt!.size.width)
//        print(tt!.size.height)
//        note = UINoteView()
//        note.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//        note.editable = true
//        getNote(withID: "-LTMeqhZ7VXfxMkYn7av")
//        view.addSubview(note)
//        // Do any additional setup after loading the view.
//            let touched = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
//        view.addGestureRecognizer(touched)
//    }
//    
//    
//    @objc func disableKeyboard(){
//        note.endEditing(true)
//    }
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//    
//    
//    private func getNote(withID noteID: String){
//        ref = Database.database().reference()
//        
//        ref.child("notes").child(noteID).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            if let value = snapshot.value as? [String : Any] {
//                
//                
//                let widgets = value["widgets"] as? [String]
//                let title = value["title"] as? String
//                let timeStamp = value["timeStamp"] as? String
//                let text = value["text"] as? [String]
//                let links = value["links"] as? [String]
//                let drawings = value["drawings"] as? [String]
//                let images = value["images"] as? [[String:String]]
//                let creator = value["creator"] as? String
//                let latitude = value["latitude"] as? Double
//                let longitude = value["longitude"] as? Double
//             //   let loadedNote = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images ?? [], linkText: linkText, linkURL: linkURL, AREnabled: AREnabled ?? false, creator: creator ?? "", timeLeft: timeLeft, location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
//                let loadedNote = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text, images: images ?? nil, links: links, drawings: drawings, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
//                
//                //UI STUFF
//                self.updateNoteView(loadedNote)
//                
//                
//                
//                
//                
//            }
//            
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//        
//        
//    }
//    
//    
//    
//    
//    
//    func updateNoteView(_ loadedNote: Note){
//        
//        
//        //NEEDS BIG FIXIN
//        var displayNote = loadedNote
//        note.clearNote()
//        
//        for widget in loadedNote.widgets {
//            switch widget{
//            case "title":
//                note.addTitleWidget(title: loadedNote.title, timeStamp: loadedNote.timeStamp, yPlacement: nil)
//                break
//            case "text":
//                if loadedNote.text != nil {
//                    note.addTextWidget(text: displayNote.text!.remove(at: 0), yPlacement: nil)
//                }
//                break
//            case "image":
//                
//                //LOAD AND ADD IMAGE
//                
//                if loadedNote.images != nil {
//                    let imageInfo = displayNote.images!.remove(at: 0)
//                    let imageUrl = imageInfo["url"]
//                    let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
//                    let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
//                    note.addImageWidget(imageURL: imageUrl!, imageWidth: imageW, imageHeight: imageH, yPlacement: nil)
//                }
//                break
//            case "drawing":
//                break;
//            case "link":
//                break
//            default:
//                break
//                
//            }
//        }
//        
//        
//        
//        //
//        //        note.title = loadedNote.title
//        //        note.time = loadedNote.timeStamp
//        //     //   note.showARButton = loadedNote.AREnabled
//        //
//        //
//        //        if let displayText = loadedNote.text {
//        //            //note.text = displayText
//        //        }
//        //        if let notepics = loadedNote.images{
//        //            for imgURL in notepics {
//        //                note.addImage(withURL: imgURL)
//        //            }
//        //        }
//        //        if let link = loadedNote.linkURL {
//        //            if let linkText = loadedNote.linkText {
//        //                note.addLink(text: linkText, url: link)
//        //            }else{
//        //                note.addLink(text: link, url: link)
//        //            }
//        //        }
//        //        UIView.transition(with: note, duration: 0.5, options: [.transitionCurlDown], animations: {
//        //            self.note.alpha = 1
//        //        },completion: {_ in})
//        //
//        //
//        
//        
//    }
//    
//    
//}
