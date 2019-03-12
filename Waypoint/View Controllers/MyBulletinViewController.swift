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
    

    private var savedNotesIDs = [String]()
    var note:UINoteView!
    var mapView:MKMapView!
    
    private var notesIDSInExpand = [String]()
    private var locationManager:CLLocationManager!
    
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
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
        note.hasSaveButton = false
        note.delegate = self
        
        view.addSubview(note)
    }
    
    private func createMapView() {
        mapView = MKMapView()
        mapView.frame = view.bounds
        mapView.isUserInteractionEnabled = false
        
        view.addSubview(mapView)
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
        createMapView()
        determineCurrentLocation()
        createNoteView()
        savedNotesIDs = []
        yPosition = 0;
        if let user = Auth.auth().currentUser {
            ref = Database.database().reference()
            ref.child("users").child(user.uid).child("saves").observeSingleEvent(of: .value) { (snapshot) in
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    if let childData = childSnapshot.value as? [String : Any] {
                        
                        if let idToAdd = childData["savedID"] as? String {
                            print(idToAdd)
                            self.savedNotesIDs.append(idToAdd)
                        }
                        
                        
                    }
                }
                
                
                for save in self.savedNotesIDs {
                    self.getNote(withID: save)
                }
                if self.savedNotesIDs.count == 0 {
                    let notesWillAppearLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/3))
                    notesWillAppearLabel.text = "Notes you save will appear here"
                    notesWillAppearLabel.textAlignment = .center
                    notesWillAppearLabel.font = UIFont(name: "Lato", size: 25)
                    self.view.addSubview(notesWillAppearLabel)
                    
                }
                
            }
            
        }else{
            let notSignedInLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/3))
            notSignedInLabel.text = "Sign in to see your saved notes"
            notSignedInLabel.textAlignment = .center
            notSignedInLabel.font = UIFont(name: "Lato", size: 25)
            self.view.addSubview(notSignedInLabel)
        }
    }
    

    private var yPosition: CGFloat = 0

    
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
            var lastYVal: CGFloat = 0
            if note.endYPositions.indices.contains(index + 1) {
                lastYVal = note.endYPositions[index + 1]
            }else {
                lastYVal = note.getScrollMax()
            }
            let nextTitleMaxY = note.nextYmax(overY: firstYVal)
            note.removeWidgetsInRange(minY: firstYVal, maxY: lastYVal)
            
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
                let timeStamp = value["timeStamp"] as? String ?? ""
                self.note.noteID = noteID
                self.notesIDSInExpand.append(noteID)
                self.note.addTitleWidget(title: title, timeStamp: timeStamp, yPlacement: nil)
                self.note.increaseScrollSlack(by: self.note.calculateHeight(of: "title", includePadding: false) * 11/12)
                
                
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
                let images = value["images"] as? [[String:String]] ?? []
                let creator = value["creator"] as? String
                let latitude = value["latitude"] as? Double
                let longitude = value["longitude"] as? Double
                var note = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images , links: links ?? nil, drawings: drawings ?? nil, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                
                var totalHeight: CGFloat = self.note.getPadding()
                
                var imagesC = images
                
                //Moves elements down
                
                for widget in note.widgets {
                    if widget == "image" {
                        let imageInfo = imagesC.remove(at: 0)
                        let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
                        let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
                        
                        totalHeight += self.note.calculateHeight(imageWidth: imageW, imageHeight: imageH, includePadding: true)
                    }else if widget != note.widgets[0]{
                        totalHeight += self.note.calculateHeight(of: widget, includePadding: true)
                    }
                }
                
                self.note.moveWidgets(overY: titleEndY, by: totalHeight, down: true)
                //Add elements in correct place
                var yPlacing: CGFloat = titleEndY + self.note.getPadding()
                for widget in note.widgets {
                    if widget != note.widgets[0] {
                        
                        
                        switch widget{
                        case "title":
                            self.note.addTitleWidget(title: note.title, timeStamp: note.timeStamp, yPlacement: yPlacing)
                            break;
                        case "text":
                            if note.text != nil {
                                self.note.addTextWidget(text: note.text!.remove(at: 0), yPlacement: yPlacing)
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
                        
                        if widget != "image" {
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