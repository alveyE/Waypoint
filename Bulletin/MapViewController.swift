//
//  ViewController.swift
//  Bulletin
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    var locationManager:CLLocationManager!
    var mapView:MKMapView!
    var note:NoteView!
    

    
    

    
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
        createMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineCurrentLocation()
    }
    
    
    @objc func mapTapped(){
        
            note.endEditing(true)
        if note.alpha == 1 {
        UIView.transition(with: note, duration: 0.5, options: [.transitionCurlUp], animations: {
            self.note.alpha = 0
        },completion: {_ in})
         //   note.textContent.isEditable = true
            note.clearNote()
        }
    }
    
    func createMapView()
    {
        
        
        
        
        
        
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
        //≥note.textContent.isEditable = false
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        // Or, if needed, we can position map in the center of the view
        mapView.center = view.center
        mapView.contentMode = .scaleToFill
        
        // Add annotations
        let noteManager = NoteManager()
        for location in noteManager.noteLocations {
                let waypoint = MKPointAnnotation()
                waypoint.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            
                mapView.addAnnotation(waypoint)
        }
        
        
        
        
        
        view.addSubview(mapView)
        mapView.addSubview(note)
        note.alpha = 0
      
        
       
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
      
        if let coordinates = view.annotation?.coordinate {
            let noteManager = NoteManager()
            for index in noteManager.noteLocations.indices {
                if coordinates.latitude == noteManager.noteLocations[index].latitude, coordinates.longitude == noteManager.noteLocations[index].longitude {
                    
                    
                    //THIS LOADED NOTE needs to be the note from server CHECK NOTE MANAGER to see how its doin it rn
                     let loadedNote = noteManager.loadNote(at: index)
                   
                    //Add Note qualities to NoteView
                    
                    
                    if let displayText = loadedNote.text {
                        note.text = displayText
                    }
                    for imgURL in loadedNote.images {
                        if let downloadedImage = noteManager.loadImage(withURL: imgURL){
                            note.addImage(downloadedImage)
                        }
                    }
                    if let link = loadedNote.linkURL {
                        if let linkText = loadedNote.linkText {
                            note.addLink(text: linkText, url: link)
                        }else{
                            note.addLink(text: link, url: link)
                        }
                    }
                    
                    
                }
            }
            
            UIView.transition(with: note, duration: 0.5, options: [.transitionCurlDown], animations: {
                self.note.alpha = 1
            },completion: {_ in})
            //TODO: Make note textview non editable also do reverse in mapTapped()
       
        }
    }


}



