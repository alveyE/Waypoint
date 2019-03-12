//
//  TitleView.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/13/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@IBDesignable
class TitleView: UIView {

    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    public var editable = false
    public var hasSaveButton = false
    public var noteTimeStamp = "20181219101034"
    public var title = ""
    public var noteID = ""
    public var saved = false {
        didSet{
            let emptyTag = UIImage(named: "tagEmpty")
            let filledTag = UIImage(named: "tagFilled")
            if self.saved {
                self.saveButton.setImage(filledTag, for: UIControl.State.normal)
            }else {
                self.saveButton.setImage(emptyTag, for: UIControl.State.normal)
            }
        }
    }
    
    
    private lazy var titleText = createTitleText()
    private lazy var timeStamp = createTimeStamp()
    private lazy var saveButton = createSaveButton()
    private lazy var shadow = createShadow()
    private lazy var calendarIcon = createCalendarIcon()
    
   var ref: DatabaseReference!

    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(titleText)
        addSubview(timeStamp)
        addSubview(calendarIcon)
        if hasSaveButton {
        addSubview(saveButton)
        }
    }
    
    private func createShadow() -> CAShapeLayer {
        let box = UIBezierPath(rect: CGRect(x: bounds.minX, y: bounds.minY, width: width, height: height))
        let boxShadow = CAShapeLayer()
        boxShadow.path = box.cgPath
        boxShadow.shadowColor = UIColor.black.cgColor
        boxShadow.shadowOpacity = 0.25
        boxShadow.shadowOffset = CGSize.zero
        boxShadow.shadowRadius = 5
        boxShadow.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
 //       boxShadow.fillColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return boxShadow
    }
    
    
    private func createTitleText() -> UITextView {
        let title = UITextView(frame: CGRect(x: width/25, y: height/50, width: width * 8/9, height: height * 3/8))
        title.isEditable = editable
        title.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
   //     title.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        title.isScrollEnabled = false
        let titleFont = UIFont(name: "Roboto-Medium", size: height/4)
        title.font = titleFont
        title.text = self.title
        
        
        return title
        
    }
    
    private func createCalendarIcon() -> UIImageView {
        let calendar = UIImage(named: "cal")
        let calendarIcon = UIImageView(frame: CGRect(x: width/18, y: height * 22/48, width: calendar!.size.width * 2/3, height: calendar!.size.height  * 2/3))
        calendarIcon.image = calendar!
        return calendarIcon
        
    }
    
    
    private func createTimeStamp() -> UILabel {
        let time = UILabel(frame: CGRect(x: width/8, y: height * 9/24, width: width * 7/9, height: height * 3/8))
        time.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let dateFont = UIFont(name: "Roboto", size: height/4.3)
        time.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//        time.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let timeText = determineHowLongAgo(noteCreationDate: noteTimeStamp)
        let attributedTime = NSMutableAttributedString(string: timeText, attributes: [.font : dateFont as Any])
        time.attributedText = attributedTime
        return time
    }
    
    private func createSaveButton() -> UIButton {
        setSavedCorrectly()
        let save = UIButton(frame: CGRect(x: width * 17/20, y: height/9, width: width/10, height: width/10))
        save.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let emptyTag = UIImage(named: "tagEmpty")
        let filledTag = UIImage(named: "tagFilled")
        if saved {
            save.setImage(filledTag, for: UIControl.State.normal)
        }else {
            save.setImage(emptyTag, for: UIControl.State.normal)
        }
        save.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        return save
        
        
    }
    
    private func setSavedCorrectly(){
        if let user = Auth.auth().currentUser {
        ref = Database.database().reference()
            ref.child("users").child(user.uid).child("saves").observeSingleEvent(of: .value, with: { (snapshot) in
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    if let childData = childSnapshot.value as? [String : Any] {
                        
                        let savedID = childData["savedID"] as? String
                        
                        if savedID! == self.noteID {
                           self.saved = true
                            print("note is saved")
                        }
                        
                        
                        
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }

        }
    }
    
    @objc private func saveTapped(){
        saved = !saved
        
        if let user = Auth.auth().currentUser {
            ref = Database.database().reference()
            
            if saved {
            let userID = ref.child("users").child(user.uid).child("saves").childByAutoId()
            userID.updateChildValues(["savedID" : noteID])
       
            }else {
                var idRetrieved = "no id found"
                ref.child("users").child(user.uid).child("saves").observeSingleEvent(of: .value, with: { (snapshot) in
                    for case let childSnapshot as DataSnapshot in snapshot.children {
                        if let childData = childSnapshot.value as? [String : Any] {
     
                            let savedID = childData["savedID"] as? String
                            
                            if savedID! == self.noteID {
                            idRetrieved = childSnapshot.key
                                
                            }
                            
                            
                            if idRetrieved != "no id found" {
                                
                                
                                self.ref.child("users").child(user.uid).child("saves").child(idRetrieved).removeValue(completionBlock: { (error, ref) in
                                    if error != nil {
                                        print(error!)
                                    }
                                })

                            }
                            
                            
                        }
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            
            }
        
        }
        
        
    }
    
    
   
    
    private func determineHowLongAgo(noteCreationDate : String) -> String {
        print(noteCreationDate)
        
        let date = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let seconds = calendar.component(.second, from: date)
        let minutes = calendar.component(.minute, from: date)
        let currentTime = String(format: "%04d%02d%02d%02d%02d%02d", year,month,day,hour,minutes,seconds)

        let nowTime = Double(currentTime) ?? 11111111111111
        let noteTime = Double(noteCreationDate) ?? 11111111111111
        if(nowTime <= noteTime){
            return "Moments ago"
        }
        else if(nowTime > noteTime && nowTime - noteTime < 240000){
            return "Today at \(parseDate(date: noteTime))"
        }
        else if(nowTime > noteTime && nowTime - noteTime > 240000){
            return "Yesterday at \(parseDate(date: noteTime))"
        }
        else{
            return "1 day ago"
        }
    }
    func parseDate(date : Double) -> String{
        
        
        
        
        
        let hourSecond = String(date)
        var hour = String(Array(hourSecond)[8...9])
        let minute = String(Array(hourSecond)[10...11])
        if (Int(hour)! > 12) {
            hour = String(Int(hour)!-12)
        }
        return "\(hour):\(minute)"
}
}



extension UIFont {
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        
        // create a new font descriptor with the given traits
        if let fd = fontDescriptor.withSymbolicTraits(traits) {
            // return a new font with the created font descriptor
            return UIFont(descriptor: fd, size: pointSize)
        }
        
        // the given traits couldn't be applied, return self
        return self
    }
    
    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }
    
    func bold() -> UIFont {
        return withTraits(.traitBold)
    }
    
    
    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }
}