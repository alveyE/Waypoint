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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate{
    var locationManager:CLLocationManager!
    var mapView:MKMapView!
    var note:NoteView! {
        didSet {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(mapTapped))
            swipeUp.direction = [.up]
            note.addGestureRecognizer(swipeUp)
        }
    }
    var scroll: UIScrollView!
    var ref: DatabaseReference!
    var locations = [(latitude: Double, longitude: Double)]()
    var noteIDs = [String]()
    var xPosition: CGFloat = 0
    
    public static var notes = [Note]()
    public static var locations = [(latitude: Double, longitude: Double)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create and Add MapView to our main view
        fetchPinLocation()
        
        createMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineCurrentLocation()
    }
    
    
    @objc func mapTapped(){
        
        scroll.subviews.forEach({ $0.removeFromSuperview() })
        scroll.addSubview(note)
        scroll.contentSize.width = note.frame.width
        xPosition = note.frame.width + note.frame.width/15
        
        for ann in mapView.annotations {
            mapView.deselectAnnotation(ann, animated: true)
        }

        note.endEditing(true)
        if note.alpha == 1 {
        UIView.transition(with: note, duration: 0.5, options: [.transitionCurlUp], animations: {
            self.note.alpha = 0
        },completion: {_ in})
         //   note.textContent.isEditable = true
            note.clearNote()
            scroll.isHidden = true
        }
        
       
    }
    
    func createMapView() {
        
        mapView = MKMapView()
        mapView.delegate = self
        let mapTapped = UITapGestureRecognizer(target: self, action: #selector(self.mapTapped))
        mapView.addGestureRecognizer(mapTapped)
        scroll = UIScrollView()
        scroll.delegate = self
        note = NoteView()
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        scroll.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight * 7/10)
        note.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight * 7/10)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        note.editable = false
        
        xPosition += note.frame.width + note.frame.width/15
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        // Or, if needed, we can position map in the center of the view
        mapView.center = view.center
        mapView.contentMode = .scaleToFill
        
        updatePins()
        
        scroll.isHidden = true
        
        
        view.addSubview(mapView)
        mapView.addSubview(scroll)
        mapView.addSubview(note)
        mapView.isUserInteractionEnabled = true

        note.alpha = 0
      
        
       
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation: CLLocation = locations[0] as CLLocation
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        
        print("Error \(error)")
    }
    

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      
        
        
        if let coordinates = view.annotation?.coordinate, view.annotation?.title != "My Location" {
         
            
            getNote(withLocation: (latitude: coordinates.latitude, longitude: coordinates.longitude), addingNote: false)

            
            
            
            let otherLocations = locations.filter({$0 != (latitude: coordinates.latitude, longitude: coordinates.longitude)})
            for coord in otherLocations {
                let locationCoordinate = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                let otherCoordinate = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                
                let distance = locationCoordinate.distance(from: otherCoordinate)
                
                if distance < 110 {
                    print("Adding with location \(coordinates.latitude) \(coordinates.longitude) compared to original location of ")
                    getNote(withLocation: (latitude: otherCoordinate.coordinate.latitude, longitude: otherCoordinate.coordinate.longitude), addingNote: true)
                }
                
                
            }
                    //THIS LOADED NOTE needs to be the note from server CHECK NOTE MANAGER to see how its doin it rn
                    scroll.isHidden = false
                    //Add Note qualities to NoteView
                    
                    
                    
                    
                
            
            
            
            //TODO: Make note textview non editable also do reverse in mapTapped()
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        view.subviews.forEach({ $0.removeFromSuperview() })
        
        createMapView()
        
    }
    
    func updateNoteView(_ loadedNote: Note){
        note.clearNote()

        note.title = loadedNote.title
        note.time = loadedNote.timeStamp
        
        
        if let displayText = loadedNote.text {
            note.text = displayText
        }
        if let notepics = loadedNote.images{
            for imgURL in notepics {
                note.addImage(withURL: imgURL)
            }
        }
        if let link = loadedNote.linkURL {
            if let linkText = loadedNote.linkText {
                note.addLink(text: linkText, url: link)
            }else{
                note.addLink(text: link, url: link)
            }
        }
        UIView.transition(with: note, duration: 0.5, options: [.transitionCurlDown], animations: {
            self.note.alpha = 1
        },completion: {_ in})
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
                        let coord = (latitude: latitude, longitude: longitude)
                        if !self.locations.contains(coord) {
                            
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
                let note = Note(title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images ?? [], linkText: linkText, linkURL: linkURL, AREnabled: AREnabled ?? false, creator: creator ?? User(username: "", password: "", id: 0), timeLeft: timeLeft, location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                if addingNote {

                    let newNoteView = NoteView()
                    
                    newNoteView.frame = CGRect(x: self.xPosition, y: 0, width: self.view.frame.width, height: self.view.frame.height * 7/10)
                    newNoteView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    
                    newNoteView.title = note.title
                    newNoteView.time = note.timeStamp
                    
                    
                    if let displayText = note.text {
                        newNoteView.text = displayText
                    }
                    if let notepics = note.images{
                        for imgURL in notepics {
                            newNoteView.addImage(withURL: imgURL)
                        }
                    }
                    if let link = note.linkURL {
                        if let linkText = note.linkText {
                            newNoteView.addLink(text: linkText, url: link)
                        }else{
                            newNoteView.addLink(text: link, url: link)
                        }
                    }

                    self.scroll.addSubview(newNoteView)
                    self.xPosition += newNoteView.frame.width +  newNoteView.frame.width/15
                    self.scroll.contentSize.width += newNoteView.frame.width +  newNoteView.frame.width/15
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


