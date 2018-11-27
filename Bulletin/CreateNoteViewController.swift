//
//  CreateNoteViewController.swift
//  Bulletin
//
//  Created by Ethan Alvey on 11/16/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import CoreLocation

class CreateNoteViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    var currentLocation = CLLocation(latitude: 0, longitude: 0)
    
    
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
    
        let noteToAdd = Note(text: noteView.textContent.text, images: [], link: nil, AREnabled: false, creator: ethanAlvey, timeLeft: 24, location: (currentLocation.coordinate.latitude,currentLocation.coordinate.longitude))
        Server.notes.append(noteToAdd)
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
