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

class CreateNoteViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddWidgetViewDelegate, UINoteViewDelegate {
    func touchHeard(onIndex index: Int) {
        
    }
    
    
    

    var locationManager:CLLocationManager!
    var currentLocation = CLLocation(latitude: 0, longitude: 0)
    var noteCreator: NoteCreator!
    
    private var yAddPosition: CGFloat = 0
    private var shouldLoad = true
    
    var note:UINoteView! {
        didSet{
            let tapped = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            note.addGestureRecognizer(tapped)
        }
    }

   
   
    
    override func viewWillDisappear(_ animated: Bool) {
     //   self.view = nil
    }
    
    @IBOutlet var mainView: UIView! {
        didSet{
        let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
        mainView.addGestureRecognizer(tap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        if shouldLoad {
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
    }
    @objc func disableKeyboard(){
        note.endEditing(true)
    }
    
    
    private func createNoteView(){
        note = UINoteView()

        let noteWidth:CGFloat = view.frame.size.width
        let noteHeight:CGFloat = view.frame.size.height
        note.frame = CGRect(x: 0, y: 0, width: noteWidth, height: noteHeight)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        note.editable = true
        note.delegate = self
        
        view.addSubview(note)
        note.addTitleWidget(title: "Enter title here", timeStamp: "", yPlacement: nil)
        note.addWidgetMaker(yPlacement: nil, adderDelegate: self)
        
        
        
    }
    
   
    func createNoteTouched(_ sender: UIButton) {
    
//              noteCreator.title = note.titleText.text
        //    noteCreator.text = note.textContent.text
        
        
        if noteCreator.text == nil, noteCreator.title == "", noteCreator.images == [] {
            //Display message to add content to note
            
          
            //Makes sure user location can be determined within 10m
        }else if currentLocation.horizontalAccuracy < 10{
        noteCreator.latitude = currentLocation.coordinate.latitude
        noteCreator.longitude = currentLocation.coordinate.longitude
            
        //DO THE WIDGET
            
        noteCreator.writeNote()
        self.tabBarController?.selectedIndex = 0
        }else{
            //Display error message that userlocation cannot accuratly be determined
            let alert = UIAlertController(title: "Cannot determine user location", message: "Your note could not be published as your device's location could not be determined accurately", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func saveWidgets(){
        
        
        
        
    }
    func addText() {
        let savedYPosition = note.widgetAdderY
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(of: "text", includePadding: true), down: true)
        note.addTextWidget(text: "Enter text here", yPlacement: savedYPosition)
        
    }
    
    func addImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        shouldLoad = false
        present(picker, animated: true, completion: nil)
    }
    
    func addDrawing() {
        
    }
    
    func addLink() {
        
    }
    
    
    func chooseImageTouched(_ sender: UIButton) {
        
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
        
        let savedYPosition = note.widgetAdderY
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(imageWidth: selectedImage.size.width, imageHeight: selectedImage.size.height, includePadding: true), down: true)
        note.addImageWidget(image: selectedImage, imageWidth: selectedImage.size.width, imageHeight: selectedImage.size.height, yPlacement: savedYPosition)
        
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
                    let imageDataToSave = ["width":"\(img.size.width)","height":"\(img.size.height)","url":urlCreated]
                    self.noteCreator.images?.append(imageDataToSave)
                }
                
                
            }
            
            
            
        }
        
    }
    

}
