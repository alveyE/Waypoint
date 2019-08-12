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
import FirebaseAuth
import MapKit

class MyBulletinViewController: UIViewController, UINoteViewDelegate, CLLocationManagerDelegate {
    func doNothing() {
       
    }

    private var savedNotesIDs = [String]()
    var note:UINoteView!
    var mapView:MKMapView!
    var errorBar:ErrorBar!
    private var notesIDSInExpand = [String]()
    private var locationManager:CLLocationManager!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
        mapView = nil
        notesIDSInExpand = []
        savedNotesIDs = []
        note.clearNote()
    }
    
    
    
    private func createNoteView(){
        note = UINoteView()
        
        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.view.frame.size.height
        note.frame = CGRect(x: 0, y: 0, width: width, height: height)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        note.editable = false
        note.hasSaveButton = true
        note.hasRefresh = true
        note.delegate = self
        errorBar = ErrorBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height/10))
        errorBar.layer.zPosition = .greatestFiniteMagnitude
        note.addSubview(errorBar)
        view.addSubview(note)
    }
    
    private func createMapView() {
        mapView = MKMapView()
        mapView.frame = view.bounds
        mapView.isUserInteractionEnabled = false
        
        view.addSubview(mapView)
    }
    
    private func checkConnectionStatus(){
        var connectionFailedCount = 0
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        for _ in 0..<10 {
            connectedRef.observe(.value) { (snapshot) in
                if !(snapshot.value as? Bool ?? false) {
                    connectionFailedCount += 1
                }
                if connectionFailedCount >= 7 {
                    self.errorBar.show()
                    
                }
            }
        }
    }
    
    func refreshPulled() {
        note.cleanClear()
        notesIDSInExpand = []
        savedNotesIDs = []
        addSavedNotes()
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(viewRegion, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mapView == nil {
        createMapView()
        determineCurrentLocation()
        createNoteView()
        savedNotesIDs = []
        yPosition = 0
        addSavedNotes()
        }
    }
    
    private func addSavedNotes(){
        
        checkConnectionStatus()
        
        if let user = Auth.auth().currentUser {
            ref = Database.database().reference()
            ref.child("users").child(user.uid).child("saves").observeSingleEvent(of: .value) { (snapshot) in
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    if let childData = childSnapshot.value as? [String : Any] {
                        
                        if let idToAdd = childData["savedID"] as? String {
                            self.savedNotesIDs.append(idToAdd)
                        }
                        
                        
                    }
                }
                
                self.savedNotesIDs.reverse()
                for save in self.savedNotesIDs {
                    self.getNote(withID: save)
                }
                if self.savedNotesIDs.count == 0 {
                    let backgroundBar = UIView(frame: CGRect(x: self.view.frame.width/20, y: self.view.frame.height/6, width: self.view.frame.width - (self.view.frame.width/10), height: self.view.frame.height/9))
                    backgroundBar.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1)
                    let notesWillAppearLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - (self.view.frame.width/10), height: self.view.frame.height/9))
                    notesWillAppearLabel.text = "Notes you save will appear here"
                    notesWillAppearLabel.textAlignment = .center
                    notesWillAppearLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    notesWillAppearLabel.font = UIFont(name: "Roboto-Regular", size: backgroundBar.frame.height * 3/10)
                    backgroundBar.addSubview(notesWillAppearLabel)
                    self.view.addSubview(backgroundBar)
                    
                }
                
            }
            
        }else{
            let backgroundBar = UIView(frame: CGRect(x: self.view.frame.width/20, y: self.view.frame.height/6, width: self.view.frame.width - (self.view.frame.width/10), height: self.view.frame.height/9))
            backgroundBar.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1)
            let notSignedInLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - (self.view.frame.width/10), height: self.view.frame.height/9))
            notSignedInLabel.text = "Sign in to see your saved notes"
            notSignedInLabel.textAlignment = .center
            notSignedInLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            notSignedInLabel.font = UIFont(name: "Roboto-Regular", size: backgroundBar.frame.height * 3/10)
            backgroundBar.addSubview(notSignedInLabel)
            self.view.addSubview(backgroundBar)
        }
    }
    

    private var yPosition: CGFloat = 0

    func displayImage(image: UIImage) {
        let imageFullScreenVC = self.storyboard!.instantiateViewController(withIdentifier: "FullScreenImage") as! FullScreenImageViewController
        imageFullScreenVC.image = image
        self.show(imageFullScreenVC, sender: self)
    }
    
    func menuAppear(withID id: String) {
      
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let ref = Database.database().reference()
        if let user = Auth.auth().currentUser {
            var username = ""
            ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    username = value["username"] as? String ?? ""
                }
            })
            var tappedNoteUser = ","
            ref.child("notes").child(id).observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    tappedNoteUser = value["creator"] as? String ?? ""
                    if username == tappedNoteUser || user.uid == tappedNoteUser {
                        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: { action in
                            let editor = EditNoteViewController()
                            self.ref.child("notes").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                                if let value = snapshot.value as? [String : Any] {
                                    
                                    
                                    let widgets = value["widgets"] as? [String]
                                    let title = value["title"] as? String
                                    let timeStamp = value["timeStamp"] as? String
                                    let text = value["text"] as? [String]
                                    let links = value["links"] as? [String]
                                    let drawings = value["drawings"] as? [String]
                                    let images = value["images"] as? [[String:String]]
                                    let creator = value["creator"] as? String
                                    let latitude = value["latitude"] as? Double
                                    let longitude = value["longitude"] as? Double
                                    let note = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images , links: links ?? nil, drawings: drawings ?? nil, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                                    editor.noteBeingEdited = note
                                    editor.idOfNote = snapshot.key
                                    self.present(editor, animated: true, completion: nil)
                                }
                            })
                            
                        }))
                        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
                            
                            let confirmAlert = UIAlertController(title: "Are you sure you would like to delete this note?", message: nil, preferredStyle: UIAlertController.Style.alert)
                            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                            confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                                self.ref.child("locations").child(id).removeValue()
                                self.ref.child("deleted").child(id).setValue(value)
                                self.ref.child("notes").child(id).removeValue()
                                self.refreshPulled()
                            }))
                            self.present(confirmAlert, animated: true, completion: nil)

                        }))
                    }else {
                        alert.addAction(UIAlertAction(title: "Report", style: UIAlertAction.Style.destructive, handler: { action in
                            if let user = Auth.auth().currentUser {
                                let reportInfo = ["reporter" : user.uid]
                                self.ref.child("reported").child(id).setValue(reportInfo)
                            }
                        }))
                    }
                }
            }
            
        }
        
        
        self.present(alert, animated: true, completion: nil)
        }
    
    
    
    func touchHeard(onIndex index: Int) {
        if notesIDSInExpand[index].first != "E" {
            let noteToBeExpanded = notesIDSInExpand[index]
            notesIDSInExpand[index] = "E" + notesIDSInExpand[index]
            
            let titleEndY = note.endYPositions[index]
            expandNoteWidgets(withID: noteToBeExpanded, titleEndY: titleEndY)
            
        }else{
            //DEEXPAND
            notesIDSInExpand[index].remove(at: notesIDSInExpand[index].startIndex)
            
            let firstYVal = note.endYPositions[index]
            var lastYVal: CGFloat? = 0
            if note.endYPositions.indices.contains(index + 1) {
                lastYVal = note.endYPositions[index + 1]
            }else {
                lastYVal = nil
            }
            var nextTitleMaxY = note.nextYmax(overY: firstYVal)
        
            note.removeWidgetsInRange(minY: firstYVal, maxY: lastYVal)
            if nextTitleMaxY == 0 {
                nextTitleMaxY = firstYVal
            }
            let totalAmnt = nextTitleMaxY - firstYVal + note.getPadding()
            note.moveWidgets(overY: firstYVal, by: totalAmnt, down: false)
            
            
            
            
            
        }
    }
    
    
    private func getNote(withID noteID: String){
        ref = Database.database().reference()
        
        ref.child("notes").child(noteID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : Any] {
                
                
                
                let title = value["title"] as? String ?? ""
                var timeStamp = value["timeStamp"] as? String ?? ""
                let username = value["creator"] as? String ?? ""
                let editedStamp = value["editedTimeStamp"] as? String
                if editedStamp != nil {
                    timeStamp = "E"+editedStamp!
                }
                self.note.noteID = noteID
                self.notesIDSInExpand.append(noteID)
                self.note.addTitleWidget(title: title, timeStamp: timeStamp, username: username, yPlacement: nil)
                
            }else{
                if let index = self.savedNotesIDs.index(of: noteID) {
                    self.savedNotesIDs.remove(at: index)
                    if let user = Auth.auth().currentUser {
                        self.ref.child("users").child(user.uid).child("saves").child(noteID).removeValue()
                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    func expandNoteWidgets(withID id: String, titleEndY: CGFloat){
        ref = Database.database().reference()
        
        ref.child("notes").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : Any] {
                
                
                let widgets = value["widgets"] as? [String]
                let title = value["title"] as? String
                let timeStamp = value["timeStamp"] as? String
                let text = value["text"] as? [String]
                let links = value["links"] as? [String]
                let drawings = value["drawings"] as? [String]
                let images = value["images"] as? [[String:String]]
                let creator = value["creator"] as? String
                let latitude = value["latitude"] as? Double
                let longitude = value["longitude"] as? Double
                var note = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images , links: links ?? nil, drawings: drawings ?? nil, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                
                var totalHeight: CGFloat = self.note.getPadding()
                
                var imagesC = images ?? []
                var textC = text ?? []
                
                //Moves elements down
                
                for widget in note.widgets {
                    if widget == "image" {
                        if imagesC.count > 0{
                        let imageInfo = imagesC.remove(at: 0)
                        let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
                        let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
                        
                        totalHeight += self.note.calculateHeight(imageWidth: imageW, imageHeight: imageH, includePadding: true)
                        }
                    }else if widget == "text" {
                        if textC.count > 0{
                            let currentText = textC.remove(at: 0)
                            totalHeight += self.note.calculateTextHeight(of: currentText, includePadding: true)
                        }
                    }else if widget != note.widgets[0]{
                        totalHeight += self.note.calculateHeight(of: widget, includePadding: true)
                    }
                }
                if note.widgets.count == 0 {
                    totalHeight = 0
                }
                self.note.moveWidgets(overY: titleEndY, by: totalHeight, down: true)
                //Add elements in correct place
                var yPlacing: CGFloat = titleEndY + self.note.getPadding()
                for widget in note.widgets {
                    if widget != note.widgets[0] {
                        
                        
                        switch widget{
                        case "title":
                            self.note.addTitleWidget(title: note.title, timeStamp: note.timeStamp, username: note.creator, yPlacement: yPlacing)
                            break;
                        case "text":
                            if note.text != nil {
                                let addedText = note.text!.remove(at: 0)
                                self.note.addTextWidget(text: addedText, yPlacement: yPlacing)
                                
                                yPlacing += self.note.calculateTextHeight(of: addedText, includePadding: true)
                            }
                            break;
                        case "image":
                            //LOAD AND ADD IMAGE
                            
                            if note.images != nil {
                                let imageInfo = note.images!.remove(at: 0)
                                let imageUrl = imageInfo["url"]
                                let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
                                let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
                                self.note.addImageWidget(imageURL: imageUrl!, imageWidth: imageW, imageHeight: imageH, yPlacement: yPlacing)
                                
                                yPlacing += self.note.calculateHeight(imageWidth: imageW, imageHeight: imageH, includePadding: true)
                            }
                            
                            break;
                        case "drawing":
                            if note.drawings != nil {
                                let drawing = note.drawings!.remove(at: 0)
                                self.note.addDrawingWidget(setImage: drawing, yPlacement: yPlacing)
                            }
                            break;
                        case "link":
                            if note.links != nil {
                                let link =  note.links!.remove(at: 0)
                                self.note.addLinkWidget(url: link, yPlacement: yPlacing)
                            }
                            break;
                        default:
                            break;
                            
                        }
                        
                        if widget != "image" && widget != "text" {
                            yPlacing += self.note.calculateHeight(of: widget, includePadding: true)
                        }
                        
                        
                        
                        
                        
                    }
                }
                
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

}
