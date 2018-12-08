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


class CreateNoteViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    var locationManager:CLLocationManager!
    var currentLocation = CLLocation(latitude: 0, longitude: 0)
    var noteCreator: NoteCreator!

    
    
    var note:NoteView! {
        didSet{
            note.textContent.delegate = self
            let tapped = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            note.addGestureRecognizer(tapped)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("TextContent Editing")
    }
    
    
    @IBOutlet var mainView: UIView! {
        didSet{
        let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
        mainView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var imageButton: UIButton!
    
    
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
        noteCreator = NoteCreator(creator: User(username: "",password: "",id: 0), latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
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
        
        let selectedText = "\(String(describing: note.textContent.selectedTextRange))"
        noteCreator.linkText = selectedText
        noteCreator.linkURL = "https://fractyldev.com"
        
    }
    @IBAction func chooseImageTouched(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
       present(picker, animated: true, completion: nil)
        
            
        
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
        
        if let img = image, let data = img.jpegData(compressionQuality: 1){
            
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
