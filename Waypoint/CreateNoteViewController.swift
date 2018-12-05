//
//  CreateNoteViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/16/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import CoreLocation

class CreateNoteViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    var currentLocation = CLLocation(latitude: 0, longitude: 0)
    
    lazy var noteMaker = NoteCreator(creator: User(username: "", password: "", id: 0), latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
    
    @IBOutlet var mainView: UIView! {
        didSet{
        let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
        mainView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var makeNote: UIButton!
    
    @IBOutlet weak var noteView: NoteView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineCurrentLocation()
        // Do any additional setup after loading the view.
    }
    
    @objc func disableKeyboard(){
        noteView.endEditing(true)
    }
    
    @IBAction func makeNoteTouched(_ sender: UIButton) {
        let ethanAlvey = User(username: "Ethan", password: "", id: 1)
        let testNote = Note(title: "Georgia", timeStamp: "", text: "Gerorgia", images: [], linkText: nil, linkURL: nil, AREnabled: false, creator: ethanAlvey, timeLeft: 24, location: (latitude: 33.7152, longitude: -84.2552))
        let testNote1 = Note(title: "Texas", timeStamp: "", text: "Texas", images: [], linkText: nil, linkURL: nil, AREnabled: false, creator: ethanAlvey, timeLeft: 24, location: (latitude: 32.3221, longitude: -99.2739))
        let testNote2 = Note(title: "Brazil", timeStamp: "", text: "Brazil", images: [], linkText: nil, linkURL: nil, AREnabled: false, creator: ethanAlvey, timeLeft: 24, location: (latitude: -11.1418, longitude: -51.7604))
        let testNote3 = Note(title: "Russia", timeStamp: "", text: "Russia", images: ["https://media-cdn.tripadvisor.com/media/photo-s/0e/9a/e3/1d/freedom-tower.jpg"], linkText: nil, linkURL: nil, AREnabled: false, creator: ethanAlvey, timeLeft: 24, location: (latitude: 63.4538, longitude: 113.4065))
        
        
        let database = DBManager()
        database.uploadPin(testNote)
        database.uploadPin(testNote1)
        database.uploadPin(testNote2)
        database.uploadPin(testNote3)
        
    
      
        
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
        let userLocation: CLLocation = locations[0] as CLLocation
        currentLocation = userLocation
    }
    

}
