//
//  ExploreNearbyNotesViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/18/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import MapKit

class ExploreNearbyNotesViewController: UIViewController, CLLocationManagerDelegate, UINoteViewDelegate {
    func doNothing() {

    }
    

    var ref: DatabaseReference!

    var note:UINoteView!
    var mapView:MKMapView!
    
    private var locationManager:CLLocationManager!
    private var currentLocation = CLLocation(latitude: 0, longitude: 0) {
        didSet{
            if notesNeeded {
                fetchPinLocation()
                notesNeeded = false
            }
        }
    }
    var errorBar:ErrorBar!
    
    private var locationsAndIDs = [(latitude: Double, longitude: Double, id: String)]()
    
    private var notesIDSInExpand = [String]()
    
    private var notesNeeded = false
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.view = nil
//        locationsAndIDs = []
//        notesIDSInExpand = []
//        note.clearNote()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        determineCurrentLocation()
        if mapView == nil {
        notesNeeded = true
        createMapView()
        createNoteView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mapView != nil{
            let defaults = UserDefaults.standard
            let satallite = defaults.bool(forKey: "satallite")
            if satallite {
                mapView.mapType = MKMapType.satellite
            }else{
                mapView.mapType = MKMapType.standard
            }
        }
    }
    
    private func createNoteView(){
    //    view.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        
        note = UINoteView()
        
        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.view.frame.size.height
        note.frame = CGRect(x: 0, y: 0, width: width, height: height)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        note.listStyle = true
        note.editable = false
        note.hasSaveButton = true
        note.hasRefresh = true
        note.delegate = self
        let headerBar = UIView(frame: CGRect(x: 0, y: 0, width: note.frame.width, height: note.frame.height/20))
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                headerBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
               headerBar.backgroundColor = #colorLiteral(red: 0.1725495458, green: 0.1713090837, blue: 0.1735036671, alpha: 1)
            }
        } else {
            headerBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        headerBar.layer.zPosition = .greatestFiniteMagnitude - 0.1
        errorBar = ErrorBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height/10))
        errorBar.layer.zPosition = .greatestFiniteMagnitude
        note.addSubview(errorBar)
        note.addSubview(headerBar)
        view.addSubview(note)
    }
    
    func refreshPulled() {
        checkConnectionStatus()
        note.cleanClear()
        locationsAndIDs = []
        notesIDSInExpand = []
        fetchPinLocation()
    }
    
    
    private func createMapView() {
        mapView = MKMapView()
        mapView.frame = view.bounds
        mapView.isUserInteractionEnabled = false
        let defaults = UserDefaults.standard
        let satallite = defaults.bool(forKey: "satallite")
        if satallite {
            mapView.mapType = MKMapType.satellite
        }
        view.addSubview(mapView)
    }

    func determineCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
        
        if let userLocation = locationManager.location?.coordinate, mapView != nil {
            
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(viewRegion, animated: false)
        }
    }
    
    func displayImage(image: UIImage) {
        let imageFullScreenVC = self.storyboard!.instantiateViewController(withIdentifier: "FullScreenImage") as! FullScreenImageViewController
        imageFullScreenVC.image = image
        imageFullScreenVC.modalPresentationStyle = .fullScreen
        self.show(imageFullScreenVC, sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        currentLocation = userLocation
    }
    
    
    private func sortBasedOnNearby(){
        locationsAndIDs.sort(by: {
           CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)) < CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude))
            
        })
    }
    
    
    @objc private func checkConnectionStatus(){
        print("Checking connection")
        var connectionFailedCount = 0
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        for _ in 0..<100 {
        connectedRef.observe(.value) { (snapshot) in
            if !(snapshot.value as? Bool ?? false) {
                connectionFailedCount += 1
            }
            if connectionFailedCount >= 99 {
                self.errorBar.show()
                
            }
        }
        } 
    }
    
    private func fetchPinLocation(){
        
        perform(#selector(checkConnectionStatus), with: nil, afterDelay: 5)
        
        
        ref = Database.database().reference()
        ref.child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                //                let key = childSnapshot.key
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    let lat = childData["latitude"] as? Double
                    let long = childData["longitude"] as? Double
                    let idRetrieved = childSnapshot.key
                    if let latitude = lat, let longitude = long {
                        
                        self.locationsAndIDs.append((latitude: latitude, longitude: longitude, id: idRetrieved))
                        
                        
                    }
                    
                }
            }
            self.determineCurrentLocation()
            self.sortBasedOnNearby()
          
            while self.locationsAndIDs.count > 1000 {
                self.locationsAndIDs.removeLast()
            }
            
            //Display notes
            for pin in self.locationsAndIDs {
                self.getNote(withID: pin.id)
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        
    }
    
    func touchHeard(onIndex index: Int) {
        if notesIDSInExpand[index].first != "E" {
            
        //    note.popTitle(index: index)
            let noteToBeExpanded = notesIDSInExpand[index]
            notesIDSInExpand[index] = "E" + notesIDSInExpand[index]
            
            
            
            let titleEndY = note.endYPositions[index]
            expandNoteWidgets(withID: noteToBeExpanded, titleEndY: titleEndY)
            note.moveToTop(index: index)
        }else{
            //DEEXPAND
           
            notesIDSInExpand[index].remove(at: notesIDSInExpand[index].startIndex)
            
            let firstYVal = note.endYPositions[index]
            var lastYVal: CGFloat? = 0
            if note.endYPositions.indices.contains(index + 1) {
                lastYVal = note.endYPositions[index + 1] - note.calculateHeight(of: "title", includePadding: false)
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
                
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
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
                    
                    alert.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
                        
                        
                        ref.child("notes").child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String : Any] {
                                let title = value["title"] as? String ?? "Waypoint"
                                let latitudeFound = value["latitude"] as? Double ?? 0.0
                                let longitudeFound = value["longitude"] as? Double ?? 0.0
                              
                                
                                let regionDistance:CLLocationDistance = 10000
                                                       let coordinates = CLLocationCoordinate2DMake(latitudeFound, longitudeFound)
                                                       let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                                                       let options = [
                                                           MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                                                           MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                                                       ]
                                                       let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                                                       let mapItem = MKMapItem(placemark: placemark)
                                                       mapItem.name = title
                                                       mapItem.openInMaps(launchOptions: options)
                            }
                        }
                        
                       
                        
                       
                    }))
                    
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
                                    editor.modalPresentationStyle = .fullScreen
                                    editor.idOfNote = snapshot.key
                                    editor.callback = {
                                        self.refreshPulled()
                                    }
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
                print(totalHeight)
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




