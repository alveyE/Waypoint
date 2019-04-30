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
class TitleView: UIView, UITextViewDelegate {

    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    public var delegate: TitleViewDelegate?
    public var editable = false
    public var hasSaveButton = false
    public var hasCalendarIcon = true
    public var noteTimeStamp = "20181219101034"
    public var title = "" {
        didSet{
            titleText.text = title
        }
    }
    public var noteID = ""
    public var username = ""
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
    
    
    public lazy var titleText = createTitleText()
    private lazy var timeStamp = createTimeStamp()
    private lazy var saveButton = createSaveButton()
    private lazy var shadow = createShadow()
    private lazy var calendarIcon = createCalendarIcon()
    private lazy var usernameLabel = createUserText()
    private lazy var menuDots = createDotsMenu()
    
   var ref: DatabaseReference!

    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(titleText)
        if !editable {
        addSubview(timeStamp)
        addSubview(usernameLabel)
        addSubview(menuDots)
        }
        if hasCalendarIcon{
        addSubview(calendarIcon)
        }
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
    
    
    private func createTitleText() -> UITextField {
        // width * 8/9
        let title = UITextField(frame: CGRect(x: width/25, y: height/50, width: width * 81/100, height: height * 3/8))
        title.isUserInteractionEnabled = editable
    //    title.isEditable = editable
        title.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
   //     title.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
 //       title.isScrollEnabled = false
 //       title.delegate = self
        let titleFont = UIFont(name: "Roboto-Medium", size: height/4)
        title.font = titleFont
        if editable {
        title.placeholder = "Enter title here"
        }else {
        title.text = self.title
        }
        
        return title
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 20    // 10 Limit Value
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
        let dateFont = UIFont(name: "Roboto", size: height/4.3)?.italics()
        
        time.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//        time.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        var timeText = noteTimeStamp
        print(timeText)
        if timeText.first == "E" {
            noteTimeStamp.removeFirst()
            timeText = "Edited " + calculateTimeDifference()
        }else{
            timeText = calculateTimeDifference()
        }
        let attributedTime = NSMutableAttributedString(string: timeText, attributes: [.font : dateFont as Any])
        time.attributedText = attributedTime
        return time
    }
    
    private func createUserText() -> UILabel {
        let usernameLabel = UILabel(frame: CGRect(x: width/30, y: height - (height/2), width: width - width/6 - width/30, height: height * 5/8))
        usernameLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        usernameLabel.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        let userfont = UIFont(name: "Roboto-LightItalic", size: height/5)
        usernameLabel.font = userfont
        usernameLabel.textAlignment = .left
        usernameLabel.text = username
        return usernameLabel
    }
    
    private func createDotsMenu() -> UIButton{
        let menuButton = UIButton(frame: CGRect(x: width * 17/20, y: height * 5/8, width: width/10, height:width/10))
        menuButton.setImage(UIImage(named: "dots"), for: UIControl.State.normal)
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        return menuButton
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
                        }
                        
                        
                        
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }

        }
    }
    
    @objc private func menuTapped(){
        delegate?.menuAppear(withID: noteID)
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
    
    
    private func calculateTimeDifference() -> String{
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyyMMddHHmmss"
        let noteTime = formatter.date(from: noteTimeStamp)
        
        let timeDif = noteTime?.timeAgoDisplay()
        return timeDif ?? ""
    }
    
    
}

extension Date {
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            if diff == 1{
                return "1 second ago"
            }
            return "\(diff) seconds ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            if diff == 1{
                return "1 minute ago"
            }
            return "\(diff) minutes ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            if diff == 1{
                return "1 hour ago"
            }
            return "\(diff) hours ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            if diff == 1{
                return "1 day ago"
            }
            return "\(diff) days ago"
        } else if monthAgo < self {
            let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
            if diff == 1{
                return "1 week ago"
            }
            return "\(diff) weeks ago"
        }
        let diff = Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
        if diff == 1{
            return "1 month ago"
        }
        return "\(diff) months ago"
        
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


protocol TitleViewDelegate: class {
    func menuAppear(withID id: String)
}
