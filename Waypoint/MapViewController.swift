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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    var locationManager:CLLocationManager!
    var mapView:MKMapView!
    var note:NoteView! {
        didSet {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(mapTapped))
            swipeUp.direction = [.up]
            note.addGestureRecognizer(swipeUp)
        }
    }
    var ref: DatabaseReference!
    var locations = [(latitude: Double, longitude: Double)]()
    
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
        }
        
       
    }
    
    func createMapView() {
        
        mapView = MKMapView()
        mapView.delegate = self
        let mapTapped = UITapGestureRecognizer(target: self, action: #selector(self.mapTapped))
        mapView.addGestureRecognizer(mapTapped)
        note = NoteView()
        
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        
        note.frame = CGRect(x: 0, y: 0, width: mapWidth, height: mapHeight * 7/10)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        note.editable = false
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        // Or, if needed, we can position map in the center of the view
        mapView.center = view.center
        mapView.contentMode = .scaleToFill
        
        updatePins()
        
        
        
        
        view.addSubview(mapView)
        mapView.addSubview(note)
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
    
//
//          CARS THIS THE FUNCTION FOR TAPPING ON ANNOTATIONS
//
//
//         WHERE IT SAYS add Note qualities to NoteView thats where note stuff happens
    
    
//
//
//
//
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      
        
        
        if let coordinates = view.annotation?.coordinate, view.annotation?.title != "My Location" {
         
                    
                    
                    //THIS LOADED NOTE needs to be the note from server CHECK NOTE MANAGER to see how its doin it rn
                    
                    getNote(withLocation: (latitude: coordinates.latitude, longitude: coordinates.longitude))
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
//        note.textContent.isEditable = true
//        note.titleText.isEditable = true
//
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
//        note.textContent.isEditable = false
 //       note.titleText.isEditable = false
    }
    
    
    func fetchPinLocation(){
        ref = Database.database().reference()
        let query = ref.child("notes").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                //                let key = childSnapshot.key
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    let lat = childData["latitude"] as? Double
                    let long = childData["longitude"] as? Double
                    
                    if let latitude = lat, let longitude = long {
                        let coord = (latitude: latitude, longitude: longitude)
                        if !self.locations.contains(coord) {
                            
                            self.locations.append((latitude: latitude, longitude: longitude))
                            self.updatePins()
                        }
                    }
                    
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        
    }
    
    
    public func getNote(withID noteID: String){
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
                self.updateNoteView(note)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    func getNote(withLocation coord: (latitude: Double, longitude: Double)){
        ref = Database.database().reference()

        
        ref.child("notes").queryOrdered(byChild: "latitude").queryEqual(toValue: coord.latitude).observeSingleEvent(of: .value, with: { (snapshot) in
            
            for case let childSnapshot as DataSnapshot in snapshot.children {
                
                let childKey = childSnapshot.key
                if childSnapshot.exists() {
                let val = childSnapshot.value as? [String : Any] ?? [:]
                let longitudeRetrieved = val["longitude"] as? Double
                    if coord.longitude == longitudeRetrieved {
                        self.getNote(withID: childKey)
                    }
                }
               

            }
        }){ (error) in
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


