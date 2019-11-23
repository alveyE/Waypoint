//
//  SettingsViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit
import FirebaseDatabase

class ProfileViewController: UIViewController, CLLocationManagerDelegate, UINoteViewDelegate {
    
    
    var ref: DatabaseReference!
    var locationManager:CLLocationManager!
    private var myNoteIDs = [String]()
    private var notesIDSInExpand = [String]()
    
    
    @IBOutlet weak var displayNameLabel: UILabel!
        
    var note:UINoteView!
    
    @IBOutlet weak var notesGroupsLabel: UILabel!
    @IBOutlet weak var notesGroupsStack: UIStackView!
    @IBOutlet weak var myGroupsButton: UIButton!
    @IBOutlet weak var myNotesButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView! {
        didSet{
            profilePicture.layer.borderWidth=3.0
            profilePicture.layer.masksToBounds = false
            profilePicture.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            profilePicture.layer.cornerRadius = profilePicture.frame.size.height/2
            profilePicture.clipsToBounds = true
        }
    }
    
    
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet{
            determineCurrentLocation()
            centerOnUser()
            let blurEffect = UIBlurEffect(style: .dark)
            
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    //always fill the view
            blurEffectView.frame = mapView.bounds
            
            blurEffectView.alpha = 0.7
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            mapView.addSubview(blurEffectView)
        }
    }
    
    func centerOnUser(){
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
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
    
    
   
        override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
            navigationItem.title = "Profile"
        let settingsIcon = UIImage(named: "settings")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsIcon, style: .plain, target: self, action: #selector(openSettings))
        determineShownElements()
        createNoteView()
        addMyNotes()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        determineShownElements()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
        notesIDSInExpand = []
        myNoteIDs = []
        note.clearNote()
    }
    
    @IBOutlet var mainView: UIView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            mainView.addGestureRecognizer(tap)
        }
    }
    
    @objc private func openSettings(){
        if let stry = self.storyboard {
        let settingsVC = stry.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.show(settingsVC, sender: self)
        }
    }
    
    
    @objc private func disableKeyboard(){
        mainView.endEditing(true)
    }
    
    
    private func createNoteView(){
        note = UINoteView()
        note.frame = CGRect(x: 0, y: notesGroupsStack.frame.maxY + notesGroupsStack.frame.height, width: view.frame.width, height: view.frame.height - myNotesButton.frame.maxY)
        note.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        note.editable = false
        note.listStyle = true
        note.hasSaveButton = true
        note.hasRefresh = true
        note.delegate = self
        view.addSubview(note)
        print(note.getScrollMax())
        
    }
    
    private func determineShownElements(){
        displayNameLabel.adjustsFontSizeToFitWidth = true
        
        if let user = Auth.auth().currentUser {
            displayNameLabel.text = user.displayName
            
        }else{
            displayNameLabel.text = ""
        }
       

    }

    //111,113,121
    @IBAction func myNotesTouched(_ sender: Any) {
        myNotesButton.setTitleColor(#colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1), for: .normal)
        myGroupsButton.setTitleColor(#colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1), for: .normal)
        note.isHidden = false
        
    }
    
    @IBAction func myGroupsTouched(_ sender: Any) {
        myGroupsButton.setTitleColor(#colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1), for: .normal)
        myNotesButton.setTitleColor(#colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1), for: .normal)
        note.isHidden = true

    }
    
    func doNothing() {
        
    }
    
    func refreshPulled() {

        print("gang gang")
        note.cleanClear()
        notesIDSInExpand = []
        myNoteIDs = []
        addMyNotes()

    }
    
    func menuAppear(withID id: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let ref = Database.database().reference()
        if let user = Auth.auth().currentUser {
            var username = ""
            ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    username = value["username"] as? String ?? ""
                }
            })
            var tappedNoteUser = ","
            ref.child("notes").child(id).observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? [String : Any] {
                    tappedNoteUser = value["creator"] as? String ?? ""
                    
                    alert.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
                        
                        
                        ref.child("notes").child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String : Any] {
                                let title = value["title"] as? String ?? "Waypoint"
                                let latitudeFound = value["latitude"] as? Double ?? 0.0
                                let longitudeFound = value["longitude"] as? Double ?? 0.0
                              
                                
                                let regionDistance:CLLocationDistance = 10000
                                                       let coordinates = CLLocationCoordinate2DMake(latitudeFound, longitudeFound)
                                                       let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                                                       let options = [
                                                           MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                                                           MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                                                       ]
                                                       let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                                                       let mapItem = MKMapItem(placemark: placemark)
                                                       mapItem.name = title
                                                       mapItem.openInMaps(launchOptions: options)
                            }
                        }
                        
                       
                        
                       
                    }))
                    
                    if username == tappedNoteUser || user.uid == tappedNoteUser {
                        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: { action in
                            let editor = EditNoteViewController()
                            self.ref.child("notes").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                                if let value = snapshot.value as? [String : Any] {
                                    
                                    
                                    let widgets = value["widgets"] as? [String]
                                    let title = value["title"] as? String
                                    let timeStamp = value["timeStamp"] as? String
                                    let text = value["text"] as? [String]
                                    let links = value["links"] as? [String]
                                    let drawings = value["drawings"] as? [String]
                                    let images = value["images"] as? [[String:String]]
                                    let creator = value["creator"] as? String
                                    let latitude = value["latitude"] as? Double
                                    let longitude = value["longitude"] as? Double
                                    let note = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images , links: links ?? nil, drawings: drawings ?? nil, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                                    editor.noteBeingEdited = note
                                    editor.idOfNote = snapshot.key
                                    editor.modalPresentationStyle = .fullScreen
                                    editor.callback = {
                                   
                                        //ADD REFRESH
                      //                  self.refreshPins()

                                        
                                    }
                                    self.present(editor, animated: true, completion: nil)
                                }
                            })
                            
                        }))
                        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in
                            let confirmAlert = UIAlertController(title: "Are you sure you would like to delete this note?", message: nil, preferredStyle: UIAlertController.Style.alert)
                            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                            confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                                self.ref.child("locations").child(id).removeValue()
                                self.ref.child("deleted").child(id).setValue(value)
                                self.ref.child("notes").child(id).removeValue()
                                //ADD REFRESH
              //                  self.refreshPins()
                            }))
                            self.present(confirmAlert, animated: true, completion: nil)

                        }))
                    }else {
                        alert.addAction(UIAlertAction(title: "Report", style: UIAlertAction.Style.destructive, handler: { action in
                            if let user = Auth.auth().currentUser {
                                let reportInfo = ["reporter" : user.uid]
                                self.ref.child("reported").child(id).setValue(reportInfo)
                            }
                        }))
                    }
                }
            }
            
            
        }
        
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addMyNotes(){
           
           
           if let user = Auth.auth().currentUser {
               ref = Database.database().reference()
               ref.child("users").child(user.uid).child("notesCreated").observeSingleEvent(of: .value) { (snapshot) in
                   for case let childSnapshot as DataSnapshot in snapshot.children {
                       if let childData = childSnapshot.value as? [String : Any] {
                           
                           if let idToAdd = childData["noteID"] as? String {
                               self.myNoteIDs.append(idToAdd)
                           }
                           
                           
                       }
                   }
                   
                self.notesGroupsLabel.text = "\(self.myNoteIDs.count) Notes"
                   self.myNoteIDs.reverse()
                   for save in self.myNoteIDs {
                       self.getNote(withID: save)
                   }
                   
               }
               
           }else{
               let backgroundBar = UIView(frame: CGRect(x: self.view.frame.width/20, y: self.view.frame.height/6, width: self.view.frame.width - (self.view.frame.width/10), height: self.view.frame.height/9))
               backgroundBar.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1)
               let notSignedInLabel = UILabel(frame: CGRect(x: 0, y: 0, width: backgroundBar.frame.width - (backgroundBar.frame.width/10), height: self.view.frame.height/9))
               notSignedInLabel.text = "Sign in to see your saved notes"
               notSignedInLabel.textAlignment = .center
               
               notSignedInLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
               notSignedInLabel.font = UIFont(name: "Roboto-Regular", size: backgroundBar.frame.height * 3/10)
               
               backgroundBar.addSubview(notSignedInLabel)
               self.view.addSubview(backgroundBar)
           }
       }
    
    private func getNote(withID noteID: String){
           ref = Database.database().reference()
           
           ref.child("notes").child(noteID).observeSingleEvent(of: .value, with: { (snapshot) in
               // Get user value
               if let value = snapshot.value as? [String : Any] {
                   
                   
                   
                   let title = value["title"] as? String ?? ""
                   var timeStamp = value["timeStamp"] as? String ?? ""
                   let username = value["creator"] as? String ?? ""
                   let editedStamp = value["editedTimeStamp"] as? String
                   if editedStamp != nil {
                       timeStamp = "E"+editedStamp!
                   }
                   self.note.noteID = noteID
                   self.notesIDSInExpand.append(noteID)
                   self.note.addTitleWidget(title: title, timeStamp: timeStamp, username: username, yPlacement: nil)
                   
               }else{
                   if let index = self.myNoteIDs.firstIndex(of: noteID) {
                       self.myNoteIDs.remove(at: index)
                       if let user = Auth.auth().currentUser {
                           self.ref.child("users").child(user.uid).child("saves").child(noteID).removeValue()
                       }
                   }
               }
               
           }) { (error) in
               print(error.localizedDescription)
           }
           
           
       }
    
    func touchHeard(onIndex index: Int) {
        
        if notesIDSInExpand[index].first != "E" {
        //    note.popTitle(index: index)

            let noteToBeExpanded = notesIDSInExpand[index]
            notesIDSInExpand[index] = "E" + notesIDSInExpand[index]
            
            let titleEndY = note.endYPositions[index]
            expandNoteWidgets(withID: noteToBeExpanded, titleEndY: titleEndY)
            note.moveToTop(index: index)
        }else{
            //DEEXPAND

            notesIDSInExpand[index].remove(at: notesIDSInExpand[index].startIndex)
            
            let firstYVal = note.endYPositions[index]
            var lastYVal: CGFloat? = 0
            if note.endYPositions.indices.contains(index + 1) {
                lastYVal = note.endYPositions[index + 1] - note.calculateHeight(of: "title", includePadding: false)
            }else {
                lastYVal = nil
            }
            var nextTitleMaxY = note.nextYmax(overY: firstYVal)
        
            note.removeWidgetsInRange(minY: firstYVal, maxY: lastYVal)
            if nextTitleMaxY == 0 {
                nextTitleMaxY = firstYVal
            }
            let totalAmnt = nextTitleMaxY - firstYVal + note.getPadding()
            note.moveWidgets(overY: firstYVal, by: totalAmnt, down: false)
            
            
            
            
            
        }
    }
    
    
    func expandNoteWidgets(withID id: String, titleEndY: CGFloat){
          ref = Database.database().reference()
          
          ref.child("notes").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
              if let value = snapshot.value as? [String : Any] {
                  
                  
                  let widgets = value["widgets"] as? [String]
                  let title = value["title"] as? String
                  let timeStamp = value["timeStamp"] as? String
                  let text = value["text"] as? [String]
                  let links = value["links"] as? [String]
                  let drawings = value["drawings"] as? [String]
                  let images = value["images"] as? [[String:String]]
                  let creator = value["creator"] as? String
                  let latitude = value["latitude"] as? Double
                  let longitude = value["longitude"] as? Double
                  var note = Note(widgets: widgets ?? [], title: title ?? "", timeStamp: timeStamp ?? "", text: text ?? nil, images: images , links: links ?? nil, drawings: drawings ?? nil, creator: creator ?? "", location: (latitude: latitude ?? 0, longitude: longitude ?? 0))
                  
                  var totalHeight: CGFloat = self.note.getPadding()
                  
                  var imagesC = images ?? []
                  var textC = text ?? []
                  
                  //Moves elements down
                  
                  for widget in note.widgets {
                      if widget == "image" {
                          if imagesC.count > 0{
                          let imageInfo = imagesC.remove(at: 0)
                          let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
                          let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
                          
                          totalHeight += self.note.calculateHeight(imageWidth: imageW, imageHeight: imageH, includePadding: true)
                          }
                      }else if widget == "text" {
                          if textC.count > 0{
                              let currentText = textC.remove(at: 0)
                              totalHeight += self.note.calculateTextHeight(of: currentText, includePadding: true)
                          }
                      }else if widget != note.widgets[0]{
                          totalHeight += self.note.calculateHeight(of: widget, includePadding: true)
                      }
                  }
                  if note.widgets.count == 0 {
                      totalHeight = 0
                  }
                  self.note.moveWidgets(overY: titleEndY, by: totalHeight, down: true)
                  //Add elements in correct place
                  var yPlacing: CGFloat = titleEndY + self.note.getPadding()
                  for widget in note.widgets {
                      if widget != note.widgets[0] {
                          
                          
                          switch widget{
                          case "title":
                              self.note.addTitleWidget(title: note.title, timeStamp: note.timeStamp, username: note.creator, yPlacement: yPlacing)
                              break;
                          case "text":
                              if note.text != nil {
                                  let addedText = note.text!.remove(at: 0)
                                  self.note.addTextWidget(text: addedText, yPlacement: yPlacing)
                                  
                                  yPlacing += self.note.calculateTextHeight(of: addedText, includePadding: true)
                              }
                              break;
                          case "image":
                              //LOAD AND ADD IMAGE
                              
                              if note.images != nil {
                                  let imageInfo = note.images!.remove(at: 0)
                                  let imageUrl = imageInfo["url"]
                                  let imageW = CGFloat((imageInfo["width"]! as NSString).floatValue)
                                  let imageH = CGFloat((imageInfo["height"]! as NSString).floatValue)
                                  self.note.addImageWidget(imageURL: imageUrl!, imageWidth: imageW, imageHeight: imageH, yPlacement: yPlacing)
                                  
                                  yPlacing += self.note.calculateHeight(imageWidth: imageW, imageHeight: imageH, includePadding: true)
                              }
                              
                              break;
                          case "drawing":
                              if note.drawings != nil {
                                  let drawing = note.drawings!.remove(at: 0)
                                  self.note.addDrawingWidget(setImage: drawing, yPlacement: yPlacing)
                              }
                              break;
                          case "link":
                              if note.links != nil {
                                  let link =  note.links!.remove(at: 0)
                                  self.note.addLinkWidget(url: link, yPlacement: yPlacing)
                              }
                              break;
                          default:
                              break;
                              
                          }
                          
                          if widget != "image" && widget != "text" {
                              yPlacing += self.note.calculateHeight(of: widget, includePadding: true)
                          }
                          
                          
                          
                          
                          
                      }
                  }
                  
                  
              }
              
          }) { (error) in
              print(error.localizedDescription)
          }
          
      }
    
    func signOutButtonPressed(_ sender: UIButton) {
        
        Auth.auth()
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        determineShownElements()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "signinNavigation")
        
    }
    

}
