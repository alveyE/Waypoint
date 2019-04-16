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
import FirebaseDatabase

class CreateNoteViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddWidgetViewDelegate, UINoteViewDelegate {
    
    
    func doNothing() {
    }
    
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
        if shouldLoad {
        self.view = nil
        }
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
            updateUsername()
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
    
    func displayImage(image: UIImage) {
        let imageFullScreenVC = self.storyboard!.instantiateViewController(withIdentifier: "FullScreenImage") as! FullScreenImageViewController
        imageFullScreenVC.image = image
        self.show(imageFullScreenVC, sender: self)
    }
    
    private func updateUsername(){
        let ref = Database.database().reference()
        if let user = Auth.auth().currentUser {
            ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    let username = value["username"] as? String ?? ""
                    self.noteCreator.creator = username
                }
            })
        }
    }
    
    private func createNoteView(){
        note = UINoteView()

        let noteWidth:CGFloat = view.frame.size.width
        let noteHeight:CGFloat = view.frame.size.height
        note.frame = CGRect(x: 0, y: 0, width: noteWidth, height: noteHeight)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        note.editable = true
        note.delegate = self
        note.hasCalanderIcon = false
        
        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height/11))
        topBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9)
        topBar.addBottomBorderWithColor(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), width: topBar.frame.height/50)
        
        
        let submitSize = (view.bounds.height/11) * 3/5
        let submitPadding = view.bounds.width/8
        let submitButton = UIButton(frame: CGRect(x: view.bounds.width - submitPadding, y: topBar.frame.height * 5/8 - submitSize/2, width: submitSize, height: submitSize))
        submitButton.setImage(UIImage(named: "check"), for: UIControl.State.normal)
        submitButton.addTarget(self, action: #selector(createNoteTouched), for: .touchUpInside)
        topBar.addSubview(submitButton)
        
        
        view.addSubview(note)
        view.addSubview(topBar)
        
        note.addTitleWidget(title: "Enter title here", timeStamp: "", username: "", yPlacement: nil)
        note.addWidgetMaker(yPlacement: nil, adderDelegate: self)
        
    }
    
   
    @objc func createNoteTouched() {
    
        noteCreator.widgets = note.listOfWidgets()
        noteCreator.title = note.titleText()
        noteCreator.text = note.listOfText()
        noteCreator.links = note.listOfLinks()
        var validLinks = true
        var linkNum = 0
        for link in noteCreator.links ?? [] {
            if !link.isValidURL(){
                if "https://\(link)".isValidURL() {
                    noteCreator.links![linkNum] = "https://\(link)"
                }else if "http://\(link)".isValidURL() {
                    noteCreator.links![linkNum] = "http://\(link)"
                }else if "www.\(link)".isValidURL(){
                    noteCreator.links![linkNum] = "www.\(link)"
                }else{
                    validLinks = false
                }
                
                
            }
            linkNum += 1
        }
        
        if !validLinks{
            let alert = UIAlertController(title: "Please enter a valid link", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if noteCreator.title == "" || noteCreator.widgets == ["title"] {
            //Display message to add content to note
            let alert = UIAlertController(title: "Please add content to your note", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
          
            //Makes sure user location can be determined within so many meters
        }else if currentLocation.horizontalAccuracy < 100{
        noteCreator.latitude = currentLocation.coordinate.latitude
        noteCreator.longitude = currentLocation.coordinate.longitude
            
       

        noteCreator.writeNote()
        (self.tabBarController!.viewControllers![0] as! MapViewController).mapView = nil
        (self.tabBarController!.viewControllers![0] as! MapViewController).shouldRecenter = true
        self.view = nil
        shouldLoad = true
        self.tabBarController?.selectedIndex = 0
        }else{
            //Display error message that userlocation cannot accuratly be determined
            let alert = UIAlertController(title: "Cannot determine user location", message: "Your note could not be published as your device's location could not be determined accurately", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
   
    func addText() {
        let savedYPosition = note.widgetAdderY
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(of: "text", includePadding: true), down: true)
        note.addTextWidget(text: "", yPlacement: savedYPosition)
        
    }
    
    func addImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        shouldLoad = false
        present(picker, animated: true, completion: nil)
    }
    func activateCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        shouldLoad = false
        present(picker, animated: true, completion: nil)
    }
    func addDrawing() {
        //UPLOAD
        shouldLoad = false
        let drawVC = self.storyboard!.instantiateViewController(withIdentifier: "DrawScreen") as! CreateDrawingViewController
        self.show(drawVC, sender: self)
        drawVC.callback = { result in
            self.uploadDrawing(result)
            let returnedDrawing = UIImage(data: result)!
            let savedYPosition = self.note.widgetAdderY
            self.note.moveWidgets(overY: self.note.widgetAdderY - 1, by: self.note.calculateHeight(of: "drawing", includePadding: true), down: true)
            self.note.addDrawingWidget(drawing: returnedDrawing, yPlacement: savedYPosition)
        }
       // createNoteTouched(UIButton())
    }
    
    func addLink() {
        let savedYPosition = note.widgetAdderY
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(of: "link", includePadding: true), down: true)
        note.addLinkWidget(url: "", yPlacement: savedYPosition)
    }
    
    
    func chooseImageTouched(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
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
    
    
    
    func uploadDrawing(_ drawingData: Data){
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
        
        let imageRef = storageRef.child("uploads").child("drawings").child(locationString).child(timeStamp)
        
        let metaDataI = StorageMetadata()
        metaDataI.contentType = "image/jpg"
        
        imageRef.putData(drawingData, metadata: metaDataI) { (metadata, error) in
            
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    print("error getting download url \(String(describing: error))")
                    return
                }
                let urlCreated = downloadURL.absoluteString
                self.noteCreator.drawings?.append(urlCreated)
                
            }
            
            
        }
        
        
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
        
        let imageRef = storageRef.child("uploads").child("images").child(locationString).child(timeStamp)
        
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

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}


extension String {
    
    private func matches(pattern: String) -> Bool {
        let regex = try! NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive])
        return regex.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: utf16.count)) != nil
    }
    
    func isValidURL() -> Bool {
        guard let url = URL(string: self) else { return false }
        if !UIApplication.shared.canOpenURL(url) {
            return false
        }
        
        let urlPattern = "^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"
        return self.matches(pattern: urlPattern)
    }
}
