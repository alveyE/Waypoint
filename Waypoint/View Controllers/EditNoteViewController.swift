//
//  EditNoteViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 4/28/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditNoteViewController: CreateNoteViewController {

    public var noteBeingEdited = Note()
    public var idOfNote = "editedID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let cancelButton = UIButton(frame: CGRect(x: 0, y: view.bounds.height/30, width: view.bounds.width * 1/4, height: view.frame.height/15))
        cancelButton.setTitle("Cancel", for: UIControl.State.normal)
        cancelButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(canceled), for: .touchUpInside)
        topBar.addSubview(cancelButton)
        
    }
    
    
    @objc func canceled(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func createNoteView() {
        super.createNoteView()
        //Add widgets already made
        note.setTitle(to: noteBeingEdited.title)
        addNoteElements()
    }
    
    private func addNoteElements(){
        for widget in noteBeingEdited.widgets {
            if widget == "text" {
                addText()
            }else if widget == "image" {
                loadInImage()
            }else if widget == "link" {
                addLink()
            }else if widget == "drawing" {
                loadInDrawing()
            }
        }
    }
    
    override func addText() {
        let savedYPosition = note.widgetAdderY
        var textFound = ""
        if noteBeingEdited.text != nil {
        if noteBeingEdited.text!.count > 0 {
            textFound = (noteBeingEdited.text?.remove(at: 0)) ?? ""
        }
        }
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateTextHeight(of: textFound, includePadding: true), down: true)
        note.addTextWidget(text: textFound, yPlacement: savedYPosition)
        
    }
    
    override func addLink() {
        let savedYPosition = note.widgetAdderY
        var link = ""
        if noteBeingEdited.links != nil {
            if noteBeingEdited.links!.count > 0 {
                link = noteBeingEdited.links!.remove(at: 0)
            }
        }
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(of: "link", includePadding: true), down: true)
        note.addLinkWidget(url: link, yPlacement: savedYPosition)
    }
    
    func loadInImage(){
        if noteBeingEdited.images != nil {
            let savedYPosition = note.widgetAdderY
        let imageData = noteBeingEdited.images!.remove(at: 0)
        noteCreator.images?.append(imageData)
        let width = CGFloat((imageData["width"]! as NSString).floatValue)
        let height = CGFloat((imageData["height"]! as NSString).floatValue)
        let url = imageData["url"]
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(imageWidth: width, imageHeight: height, includePadding: true), down: true)
        note.addImageWidget(imageURL: url!, imageWidth: width, imageHeight: height, yPlacement: savedYPosition)
        }
    }
    
    func loadInDrawing(){
        if noteBeingEdited.drawings != nil {
        let drawingURL = noteBeingEdited.drawings!.remove(at: 0)
        noteCreator.drawings?.append(drawingURL)
        let savedYPosition = note.widgetAdderY
        note.moveWidgets(overY: note.widgetAdderY - 1, by: note.calculateHeight(of: "drawing", includePadding: true), down: true)
        note.addDrawingWidget(setImage: drawingURL, yPlacement: savedYPosition)
        }
    }
    

    @objc override func createNoteTouched() {
        
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
            

        }else{
            
            if noteCreator.widgets.count > 10 {
                let alert = UIAlertController(title: "Too many widgets", message: "Your note could not be published your note contains more than 10 widgets.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
            
            noteCreator.latitude = noteBeingEdited.latitude
            noteCreator.longitude = noteBeingEdited.longitude
            noteCreator.timeStamp = noteBeingEdited.timeStamp
            noteCreator.writeNote(to: idOfNote)
            callback?()
             self.dismiss(animated: true, completion: nil)

            }
            }
       
    }
   
    public var callback : (()->())?
    
}
