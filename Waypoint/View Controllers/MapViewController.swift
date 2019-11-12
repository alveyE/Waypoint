//
//  ViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseUI

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINoteViewDelegate{
    

    var locationManager:CLLocationManager!
    public var mapView:MKMapView!
    var errorBar:ErrorBar!
    var note:UINoteView! {
        didSet {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(noteSwiped))
            swipeLeft.direction = [.right]
            note.addGestureRecognizer(swipeLeft)
            
            //let noteTap = UITapGestureRecognizer(target: self, action: #selector(doNothing))
           // note.addGestureRecognizer(noteTap)
        }
    }
    

    var ref: DatabaseReference!
    var locations = [(latitude: Double, longitude: Double)]()
    var noteIDs = [String]()
    var notesIDSInExpand = [String]()
    var timeRefreshed = NSDate()
    public var shouldRecenter = true
    
    let minutesInactiveBeforeRefresh = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.view = nil
//        locations = []
//        noteIDs = []
//        notesIDSInExpand = []
        
        timeRefreshed = NSDate()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let timeDifference = timeRefreshed.timeIntervalSinceNow
        
        if timeDifference < minutesInactiveBeforeRefresh * -60 {
            mapView = nil
            shouldRecenter = true
        }
        determineCurrentLocation()
       
        if mapView == nil {
        fetchPinLocation()
        createMapView()
        
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mapView != nil, shouldRecenter {
        centerOnUser()
        shouldRecenter = false
        }
    }
    
    
    func touchHeard(onIndex index: Int) {
        //EXPAND NOTE TILE BASED ON INDEX GIVEN
        
        if notesIDSInExpand.indices.contains(index){
        
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
        
        
    }
    
    func doNothing(){}
    
    @objc func refreshPins(){
        mapTapped()
        noteIDs = []
        notesIDSInExpand = []
        locations = []
        mapView.annotations.forEach({mapView.removeAnnotation($0)})
        fetchPinLocation()
        timeRefreshed = NSDate()
        
    }
        
        
    @objc func noteSwiped(){
            let savedX = note.frame.origin.x
        UIView.animate(withDuration: 0.3, animations: {
            self.note.frame.origin.x *= 2.5
        }) { (true) in
            self.note.frame.origin.x = savedX
        }
        mapTapped()
    }
    
    @objc func mapTapped(){
        checkConnectionStatus()
        for ann in mapView.annotations {
            mapView.deselectAnnotation(ann, animated: true)
        }
        
        note.endEditing(true)
        notesIDSInExpand = []
        
        note.hide()
        note.clearNote()
    }
    
    func createMapView() {
        
        mapView = MKMapView()
        mapView.delegate = self
        let mapTapped = UITapGestureRecognizer(target: self, action: #selector(self.mapTapped))
        mapView.addGestureRecognizer(mapTapped)

        note = UINoteView()
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        note.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight * 7/10)
        note.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 0)
        
        
        let bottomBar = NoteBar()
        let barHeight = (mapHeight * 7/10)/40
        bottomBar.frame = CGRect(x: mapWidth/70, y: note.frame.height - barHeight, width: mapWidth - (mapWidth/70)*2, height: barHeight)
        bottomBar.layer.zPosition = .greatestFiniteMagnitude
    
        note.editable = false
        note.hasSaveButton = true
        note.delegate = self
        note.hide()
        note.addSubview(bottomBar)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.tintColor = #colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1)
        
        mapView.center = view.center
        mapView.contentMode = .scaleToFill
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        
        errorBar = ErrorBar(frame: CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight/10))
        errorBar.layer.zPosition = .greatestFiniteMagnitude
        let refreshSize = mapWidth/10
        let refreshPadding = mapWidth/15
        let refreshButton = UIButton(frame: CGRect(x: mapWidth - refreshPadding - refreshPadding, y: mapHeight - mapHeight/10 - refreshSize - refreshPadding, width: refreshSize, height: refreshSize))
        let refreshImage = UIImage(named: "refresh")
        refreshButton.setImage(refreshImage, for: UIControl.State.normal)
        refreshButton.addTarget(self, action: #selector(refreshPins), for: .touchUpInside)
        
        let recenterButton = UIButton(frame: CGRect(x: mapWidth - refreshPadding - refreshPadding, y: mapHeight - mapHeight/10 - refreshSize*2 - refreshPadding*2, width: refreshSize, height: refreshSize))
        recenterButton.setImage(UIImage(named: "center"), for: UIControl.State.normal)
        recenterButton.addTarget(self, action: #selector(centerOnUser), for: .touchUpInside)
        
        let groupsButton = UIButton(frame: CGRect(x: refreshPadding * 2, y: refreshPadding*2, width: refreshSize, height: refreshSize))
        groupsButton.setImage(UIImage(named: "add"), for: UIControl.State.normal)
        groupsButton.addTarget(self, action: #selector(groupsTouched), for: .touchUpInside)
        
        
        mapView.addSubview(refreshButton)
        mapView.addSubview(recenterButton)
       // mapView.addSubview(groupsButton)
        
        updatePins()
        
        view.addSubview(mapView)
        mapView.addSubview(note)
        mapView.addSubview(errorBar)
        mapView.isUserInteractionEnabled = true

    }
    
    @objc private func groupsTouched(){
        let groupManager = GroupManagerViewController()
        self.present(groupManager, animated: true)
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
    
    func updatePins(){
        // Add annotations

        for location in locations {
            
            let waypoint = MKPointAnnotation()
            waypoint.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            mapView.removeAnnotation(waypoint)
            mapView.addAnnotation(waypoint)
            
        }

    }
    
    @objc func centerOnUser(){
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }
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
        

    }
    
    func displayImage(image: UIImage) {
        let imageFullScreenVC = self.storyboard!.instantiateViewController(withIdentifier: "FullScreenImage") as! FullScreenImageViewController
        imageFullScreenVC.image = image
        imageFullScreenVC.modalPresentationStyle = .fullScreen
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
                    
                    alert.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
                        
                        
                        ref.child("notes").child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String : Any] {
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
                                                       mapItem.name = "Place Name"
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
                                    editor.idOfNote = snapshot.key
                                    editor.modalPresentationStyle = .fullScreen
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
                                self.refreshPins()
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
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation: CLLocation = locations[0] as CLLocation
        
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
        print("Error \(error)")
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        for view in views {
            if view.annotation?.isKind(of: MKUserLocation.self) ?? false {
                view.canShowCallout = false
                view.isEnabled = false
            }
        }
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title != "My Location" {
            let reuseIdentifier = "annotationView"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if #available(iOS 11.0, *) {
                if view == nil {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                }
                view?.displayPriority = .required
            } else {
                if view == nil {
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                }
            }
            view?.annotation = annotation
            view?.canShowCallout = true
            return view
        }else {
            return nil
        }
    }


    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        checkConnectionStatus()
        
        if let coordinates = view.annotation?.coordinate, view.annotation?.title != "My Location" {

            
            
            var singleAdd = true
            let otherLocations = locations.filter({$0 != (latitude: coordinates.latitude, longitude: coordinates.longitude)})
            for coord in otherLocations {
                let locationCoordinate = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                let otherCoordinate = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                
                let distance = locationCoordinate.distance(from: otherCoordinate)
                
                if distance < 110 {
                    if singleAdd {
                        getNote(withLocation: (latitude: coordinates.latitude, longitude: coordinates.longitude), addingNote: true)
                    }
                    singleAdd = false
                    print("Adding with location \(coordinates.latitude) \(coordinates.longitude) compared to original location of ")
                    
                    note.unHide()
                 //   note.trimExcess()

                    
                    
                    getNote(withLocation: (latitude: otherCoordinate.coordinate.latitude, longitude: otherCoordinate.coordinate.longitude), addingNote: true)
                }
                
                
            }
            if singleAdd {
                getNote(withLocation: (latitude: coordinates.latitude, longitude: coordinates.longitude), addingNote: false)
            }
                    
                    
                    
                
            
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        view.subviews.forEach({ $0.removeFromSuperview() })
        
        createMapView()
        
    }

    
    
    func updateNoteView(_ loadedNote: Note){
        
        
            var displayNote = loadedNote
      //      note.clearNote()
           note.unHide()
        

        for widget in loadedNote.widgets {
            switch widget{
            case "title":
                note.addTitleWidget(title: loadedNote.title, timeStamp: loadedNote.timeStamp, username: loadedNote.creator, yPlacement: nil)
                print("title ADD")
                break;
            case "text":
                if loadedNote.text != nil {
                    note.addTextWidget(text: displayNote.text!.remove(at: 0), yPlacement: nil)
                }
                break;
            case "image":
                //LOAD AND ADD IMAGE
                
                if loadedNote.images != nil {
                    let imageInfo = displayNote.images!.remove(at: 0)
                    let imageUrl = imageInfo["url"]
                    let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
                    let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
                    note.addImageWidget(imageURL: imageUrl!, imageWidth: imageW, imageHeight: imageH, yPlacement: nil)
                }
                
                break;
            case "drawing":
                if loadedNote.drawings != nil {
                    let drawing = displayNote.drawings!.remove(at: 0)
                    note.addDrawingWidget(setImage: drawing, yPlacement: nil)
                }
                break;
            case "link":
                if loadedNote.links != nil {
                    let link = displayNote.links!.remove(at: 0)
                    note.addLinkWidget(url: link, yPlacement: nil)
                }
                break;
            default:
                break;
                
            }
        }

          //  note.trimExcess()
        
    }
    
    
    func fetchPinLocation(){
        ref = Database.database().reference()
        ref.child("locations").observeSingleEvent(of: .value, with: { (snapshot) in
           
            for case let childSnapshot as DataSnapshot in snapshot.children {
                //                let key = childSnapshot.key
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    let lat = childData["latitude"] as? Double
                    let long = childData["longitude"] as? Double
                    let idRetrieved = childSnapshot.key
                    if let latitude = lat, let longitude = long {
                        if !self.noteIDs.contains(idRetrieved) {
                            
                            self.locations.append((latitude: latitude, longitude: longitude))
                            self.noteIDs.append(idRetrieved)
                            self.updatePins()
                        }
                    }
                    
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        
    }
    
    
   
    
    public func getNote(withID noteID: String, addingNote: Bool){
        ref = Database.database().reference()

        ref.child("notes").child(noteID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : Any] {
                print("DOWNLOADING \(noteID)")
                let widgets = value["widgets"] as? [String]
                let title = value["title"] as? String
                var timeStamp = value["timeStamp"] as? String
                let text = value["text"] as? [String]
                let links = value["links"] as? [String]
                let drawings = value["drawings"] as? [String]
                let images = value["images"] as? [[String:String]]
                let creator = value["creator"] as? String
                let latitude = value["latitude"] as? Double
                let longitude = value["longitude"] as? Double
                let editedStamp = value["editedTimeStamp"] as? String
                if editedStamp != nil {
                    timeStamp = "E"+editedStamp!
                }
                let note = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images ?? nil, links: links ?? nil, drawings: drawings ?? nil, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
              
                self.note.noteID = noteID
                
                if addingNote {
                    print(noteID)
                    self.notesIDSInExpand.append(noteID)
                    self.note.addTitleWidget(title: note.title, timeStamp: note.timeStamp, username: note.creator, yPlacement: nil)
                 //   self.note.increaseScrollSlack(by: self.note.calculateHeight(of: "title", includePadding: false) * 11/12)

                
                
                }else{
        
                    self.updateNoteView(note)
                    
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    
    func getNote(withLocation coord: (latitude: Double, longitude: Double), addingNote: Bool){
     
        if let indexFound = locations.firstIndex(where: {$0==coord}) {
            getNote(withID: noteIDs[indexFound],addingNote: addingNote)
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



extension Array {
    func contains(_ element: (latitude: Double, longitude: Double)) -> Bool{
        
        for elem in self {
            if let coord = elem as? (latitude: Double, longitude: Double) {
                if coord == element {
                    return true
                }
            }
        }
        return false
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
