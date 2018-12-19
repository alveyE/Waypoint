//
//  ExploreNearbyNotesViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/18/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

class ExploreNearbyNotesViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    var ref: DatabaseReference!

    
    private var locationManager:CLLocationManager!
    private var currentLocation = CLLocation(latitude: 0, longitude: 0)
    
    private var locationsAndIDs = [(latitude: Double, longitude: Double, id: String)]()
    
    private var yPosition: CGFloat = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
        locationsAndIDs = []
        yPosition = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        fetchPinLocation()
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
    
    
    private func sortBasedOnNearby(){
        locationsAndIDs.sort(by: {
           CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)) < CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude))
            
        })
    }
    
    
    
    private func fetchPinLocation(){
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
            //Display notes
            for pin in self.locationsAndIDs {
                self.getNote(withID: pin.id)
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
        
    }
    
    private func getNote(withID noteID: String){
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
                let creator = value["creator"] as? String
                let timeLeft = value["timeLeft"] as? Int
                let latitude = value["latitude"] as? Double
                let longitude = value["longitude"] as? Double
                let loadedNote = Note(title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images ?? [], linkText: linkText, linkURL: linkURL, AREnabled: AREnabled ?? false, creator: creator ?? "", timeLeft: timeLeft, location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                
                let noteView = NoteView()
                
                let width: CGFloat = self.view.frame.size.width
                let height: CGFloat = self.view.frame.size.height
                noteView.frame = CGRect(x: 0, y: self.yPosition, width: width, height: height * 7/10)
                noteView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                
                noteView.editable = false
                
                
                noteView.title = loadedNote.title
                noteView.time = loadedNote.timeStamp
                
                if let displayText = loadedNote.text {
                    noteView.text = displayText
                }
                if let notepics = loadedNote.images{
                    for imgURL in notepics {
                        noteView.addImage(withURL: imgURL)
                    }
                }
                if let link = loadedNote.linkURL {
                    if let linkText = loadedNote.linkText {
                        noteView.addLink(text: linkText, url: link)
                    }else{
                        noteView.addLink(text: link, url: link)
                    }
                }
                
                self.scrollView.addSubview(noteView)
                self.yPosition += noteView.frame.height + height/15
                self.scrollView.contentSize.height += noteView.frame.height + height/15
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }

}




