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
import FirebaseAuth

class CreateNoteViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var locationManager:CLLocationManager!
    var currentLocation = CLLocation(latitude: 0, longitude: 0)
    var noteCreator: NoteCreator!
    
    
    var note:NoteView! {
        didSet{
            let tapped = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            note.addGestureRecognizer(tapped)
        }
    }

   
   
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
    }
    
    @IBOutlet var mainView: UIView! {
        didSet{
        let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
        mainView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var createNoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createNoteView()
//        view.bringSubviewToFront(imageButton)
//        view.bringSubviewToFront(linkButton)
//        view.bringSubviewToFront(createNoteButton)
        if let user = Auth.auth().currentUser {
    noteCreator = NoteCreator(creator: user.uid, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }else{
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let notSignedInLabel = UILabel(frame: self.view.bounds)
            notSignedInLabel.text = "Please sign in to create notes"
            notSignedInLabel.textAlignment = .center
            notSignedInLabel.font = UIFont(name: "Arial", size: 25)
            
            
            view.addSubview(blurEffectView)
            view.addSubview(notSignedInLabel)
        }
    }
    @objc func disableKeyboard(){
        note.endEditing(true)
    }
    
   
    
    @IBAction func createNoteTouched(_ sender: UIButton) {
    
        
        
        if note.titleText.text != "" {
            noteCreator.title = note.titleText.text
        }
        if note.textContent.text != "" {
            noteCreator.text = note.textContent.text
        }
        
        if noteCreator.text == "", noteCreator.title == "", noteCreator.images == [] {
            
            print("Add content to note")
        }else{
        noteCreator.latitude = currentLocation.coordinate.latitude
        noteCreator.longitude = currentLocation.coordinate.longitude
        noteCreator.writeNote()
        self.tabBarController?.selectedIndex = 0
        }
    }
    @IBAction func setLinkTouched(_ sender: UIButton) {
        
        let selectedText = note.textContent.selectedTextRange
        
        noteCreator.linkText = "GRSK aldk8352 ks9"
        noteCreator.linkURL = "https://fractyldev.com"
        
    }
    @IBAction func chooseImageTouched(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
       present(picker, animated: true, completion: nil)
        
            
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.editedImage] as? UIImage else {
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
        view.sendSubviewToBack(note)
     
  
    }
    

    
    
    
    func uploadImage(_ image: UIImage?){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        determineCurrentLocation()
        
        let date = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        var hour = calendar.component(.hour, from: date)
        if hour > 12 {
            hour -= 12
        }
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let nanoSeconds = calendar.component(.nanosecond, from: date)
        let timeStamp = "\(day)\(month)\(year)\(hour):\(minutes)\(seconds)\(nanoSeconds)"
        let locationString = "\(currentLocation.coordinate.latitude)\(currentLocation.coordinate.longitude)"
        
        let imageRef = storageRef.child("uploads").child(locationString).child(timeStamp)
        
        if let img = image, let data = img.jpegData(compressionQuality: 0.5){
            
            let metaDataI = StorageMetadata()
            metaDataI.contentType = "image/jpg"
          
            imageRef.putData(data, metadata: metaDataI) { (metadata, error) in
               
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print("error getting download url \(String(describing: error))")
                        return
                    }
                    print(downloadURL)
                    let urlCreated = downloadURL.absoluteString
                    print(urlCreated)
                    self.noteCreator.images.append(urlCreated)
                    self.note.addImage(withURL: urlCreated)
                }
                
                
            }
            
            
            
        }
        
    }
    

}
