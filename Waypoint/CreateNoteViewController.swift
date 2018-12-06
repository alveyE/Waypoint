//
//  CreateNoteViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/16/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseStorage


class CreateNoteViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var locationManager:CLLocationManager!
    var currentLocation = CLLocation(latitude: 0, longitude: 0)


    
    var note:NoteView! {
        didSet{
            let tapped = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
          //  note.addGestureRecognizer(tapped)
        }
    }
    
    
    
    @IBOutlet var mainView: UIView! {
        didSet{
        let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
        mainView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var makeNote: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createNoteView()

    }
    @objc func disableKeyboard(){
        note.endEditing(true)
    }
    
    @IBAction func makeNoteTouched(_ sender: UIButton) {
        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        present(picker, animated: true, completion: nil)
        
            
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        uploadImage(selectedImage)
        dismiss(animated: true, completion: nil)
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
    
    private func createNoteView(){
        
        
        
        
        
        
        note = NoteView()
    
        
      
        
        let noteWidth:CGFloat = view.frame.size.width
        let noteHeight:CGFloat = view.frame.size.height
        note.frame = CGRect(x: 0, y: 0, width: noteWidth, height: noteHeight * 7/10)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        note.title = "Enter title"
        note.text = "Enter text here"
        
        view.addSubview(note)
     
  
    }
    

    
    
    
    func uploadImage(_ image: UIImage?){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("upload")
        
        if let img = image, let data = img.jpegData(compressionQuality: 1){
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            imageRef.putData(data, metadata: metaData)
            
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    print("GOT IT DD \(downloadURL)")
            }
            
        }
        
    }
    

}
