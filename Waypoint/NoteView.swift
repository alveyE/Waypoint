//
//  NoteView.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth

class NoteView: UIView {
    
    
    // public var noteColor = #colorLiteral(red: 1, green: 0.9230569365, blue: 0.3114053169, alpha: 1)
//    public var noteColor = UIColor(red: 1, green: 0.9230569365, blue: 0.3114053169, alpha: 1){
//        didSet{
//            setNeedsDisplay()
//            setNeedsLayout()
//        }
//    }
    public var noteColor = #colorLiteral(red: 1, green: 0.9230569365, blue: 0.3114053169, alpha: 1){
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    //public var foldColor = #colorLiteral(red: 1, green: 0.8495431358, blue: 0.1709763357, alpha: 1)
    
    public var foldColor: UIColor {
        return UIColor(red: noteColor.cgColor.components![0], green: noteColor.cgColor.components![1] - 0.0735138007, blue: noteColor.cgColor.components![2] - 0.1404289812, alpha: 1)
    }
    public var textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var text = "" {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var title = "" {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var time = "" {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var link = ("","") {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    private var imageUrls: [String] = [] {
        didSet{
    
            createImages()
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var attributedText: NSAttributedString? {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var noteID = ""
    
    
    private var hasDrawn = false
    public var editable = true
    public var hasSaveButton = false
    
    var ref: DatabaseReference!
    
    private lazy var yPosition = height * 10/48
    
    
    lazy var titleText = createTitleText()
    private lazy var timeText = createTimeText()
  
    public var saveButton: UIButton! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(saveNote))
            saveButton.addGestureRecognizer(tap)
        }
    }
    
    lazy var textContent = createTextContent()
  
    private var displayImages = [UIImageView]() {
        didSet{
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    private lazy var width: CGFloat = bounds.width
    private lazy var height: CGFloat = bounds.height
    
    
    //private var font = UIFont(name: "Marker Felt", size: 30)
    private var font = UIFont(name: "Prompt-Regular", size: 30)
    @objc private func saveNote(){
        if let user = Auth.auth().currentUser {
            
            ref = Database.database().reference()
            let userID = ref.child("users").child(user.uid).child("saves").childByAutoId()
            userID.updateChildValues(["savedID" : noteID])
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        width = bounds.width
        height = bounds.height


        
//        Making square missing bottom right triangle
        
        let cornerCut = width/6
        
        let outlinePath = UIBezierPath()
        outlinePath.move(to: CGPoint(x: width, y: 0))
        outlinePath.addLine(to: CGPoint(x: 0, y: 0))
        outlinePath.addLine(to: CGPoint(x: 0, y: height))
        outlinePath.addLine(to: CGPoint(x: width - cornerCut, y: height))
        outlinePath.addLine(to: CGPoint(x: width, y: height - cornerCut))
        outlinePath.close()
        
        let triangleFold = UIBezierPath()
        triangleFold.move(to: CGPoint(x: width, y: height - cornerCut))
        triangleFold.addLine(to: CGPoint(x: width - cornerCut, y: height))
        triangleFold.addLine(to: CGPoint(x: width - cornerCut, y: height - cornerCut))
        triangleFold.close()
        
        let titleBar = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height * 9/48))
        triangleFold.append(titleBar)
        
        noteColor.setFill()
        outlinePath.fill()

        if !hasDrawn {
            clip()
           font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font!)
            for family: String in UIFont.familyNames
            {
                print(family)
                for names: String in UIFont.fontNames(forFamilyName: family)
                {
                    print("== \(names)")
                }
            }
            
            
        let triangleShape = CAShapeLayer()
        
        triangleShape.path = triangleFold.cgPath
        triangleShape.fillColor = foldColor.cgColor
        triangleShape.shadowColor = UIColor.black.cgColor
        triangleShape.shadowOpacity = 0.5
        triangleShape.shadowOffset = CGSize.zero
        triangleShape.shadowRadius = 5
        
        layer.addSublayer(triangleShape)
        }
        
        hasDrawn = true
    }
    
    private func createImages(){
        
        
        for imgurl in imageUrls {
      
        
         //   let spacing: CGFloat = 8
            
            
       //     let adjustedWidth = width - width / spacing
     //       let adjustedHeight = height - (height / (spacing/2))
            let adjustedWidth = width/2
            let adjustedHeight = height/2
            
            
            
            let storage = Storage.storage()
            let imgadjurl = imgurl + ".jpg"
            let reference = storage.reference(forURL: imgadjurl)
            
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            
            var image = UIImage()
            reference.getData(maxSize: 2 * 1024 * 1024) { data, error in
                
                if let error = error {
                    print("error \(error)")
                } else {
                    
                    image = UIImage(data: data!) ?? UIImage()
                    if image.size.height > image.size.width {
                        
                        let imageView = UIImageView(frame: CGRect(x: (self.width/2) - ((image.size.width * (adjustedHeight/image.size.height))/2), y: self.yPosition, width: image.size.width * (adjustedHeight/image.size.height), height: adjustedHeight))
                        
                        imageView.image = image
                        print("appending")
                        self.displayImages.append(imageView)

                        self.yPosition += imageView.frame.height + self.height/25
                        
                        
                        
                    }else {
                        let imageView = UIImageView(frame: CGRect(x: self.width/2 - adjustedWidth/2, y: self.yPosition, width: adjustedWidth, height: image.size.height * (adjustedWidth/image.size.width)))
                        imageView.image = image
                        self.displayImages.append(imageView)
                        self.yPosition += imageView.frame.height + self.height/25
                        
                        }
                    
                    
                    }
                
                    }
        }
        
    
        
    }
    
    private func clip(){
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach({ $0.removeFromSuperview() })
        yPosition = height * 10/48

        textContent = createTextContent()
        titleText = createTitleText()
        timeText = createTimeText()
        saveButton = createSaveButton()
        
        
        addSubview(titleText)
        addSubview(timeText)
        addSubview(textContent)
        if hasSaveButton {
        addSubview(saveButton)
        }
        for image in displayImages {
            addSubview(image)
        }
        
    }
    
    
    private func createTextContent() -> UITextView{
        
        //calculate height
        
        let estimatedLines: CGFloat = CGFloat(text.count)/7
        var textHeight = height * 2/25 * estimatedLines

        if editable {
            textHeight = height * 2/5
        }
       
        let textField = UITextView(frame: CGRect(x: width/2 - (width*3/5)/2 , y: yPosition, width: width * 3/5, height: textHeight))
        textField.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        textField.isEditable = editable
        
        
        if text != "" {
            textField.font = font
            textField.textAlignment = .center
            
            
            if attributedText != nil {
                textField.attributedText = attributedText
            }else{
                textField.text = text
            }
            textField.textColor = textColor
            yPosition += textField.frame.height + self.height/25

        }
        return textField
    }
    
    private func createSaveButton() -> UIButton {
        let saveButton = UIButton(frame: CGRect(x: width * 9/10, y: height/12, width: width/20, height: width/20))
        let tag = UIImage(named: "tag")
        saveButton.setImage(tag, for: UIControl.State.normal)
   //     saveButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        return saveButton
        
    }
    
    
    private func createTimeText() -> UILabel {
        let timeLabel = UILabel(frame: CGRect(x: width/20, y: height * 13/96, width: width - width/10, height: height * 1/24))
        
        let fontTime = UIFont(name: "Marker Felt", size: 15)
        timeLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: fontTime!)
        timeLabel.text = time
        timeLabel.textColor = textColor
        
        return timeLabel
        
    }
    
    private func createTitleText() -> UITextView {
        let titleTextView = UITextView(frame: CGRect(x: width/20, y: height/24, width: width, height: height * (7/48)))
        titleTextView.isEditable = editable
        titleTextView.font = font
        titleTextView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        titleTextView.text = title
        titleTextView.textColor = textColor
        
        return titleTextView
    }
    
    
    public func addImage(withURL imageAdding: String){
        imageUrls.append(imageAdding)
    }
    
    
    
    
    public func addLink(text: String, url: String){
        
        let markerFelt = UIFont(name: "Marker Felt", size: 30)
        let centeredText = NSMutableParagraphStyle()
        centeredText.alignment = .center
        let attributes: [NSAttributedString.Key:Any] = [
            .font : markerFelt!,
            .paragraphStyle : centeredText
        ]
        let linkedText = NSMutableAttributedString(string: self.text, attributes: attributes)
        let hyperlinked = linkedText.setAsLink(textToFind: text, linkURL: url)
        
        if hyperlinked {
            attributedText = NSAttributedString(attributedString: linkedText)
        }
    }
    
    public func clearNote(){
        title = ""
        time = ""
        text = ""
        link = ("","")
        attributedText = nil
        displayImages = []
        imageUrls = []
     //   subviews.forEach({ $0.removeFromSuperview() })
    }

    
    
    
    
 

}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}





extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            
            self.addAttribute(.link, value: linkURL, range: foundRange)
            
            return true
        }
        return false
    }
}




