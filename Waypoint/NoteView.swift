//
//  NoteView.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseStorage

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
    
    
    private var hasDrawn = false
    public var editable = true
    
    
    private lazy var yPosition = height * 10/48
    
    
    lazy var titleText = createTitleText()
    private lazy var timeText = createTimeText()
    lazy var textContent = createTextContent()
  
    private var displayImages = [UIImageView]() {
        didSet{
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    private lazy var width: CGFloat = bounds.width
    private lazy var height: CGFloat = bounds.height
    
    
    private var font = UIFont(name: "Marker Felt", size: 30)
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        width = bounds.width
        height = bounds.height
        yPosition = height * 10/48


        
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
      
            
            let spacing: CGFloat = 8
            
            
            let adjustedWidth = width - width / spacing
            let adjustedHeight = height - (height / (spacing/2))
            
            
            
            
            let storage = Storage.storage()
            let imgadjurl = imgurl + ".jpg"
            let reference = storage.reference(forURL: imgadjurl)
            
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            
            var image = UIImage()
            reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                
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
                        let imageView = UIImageView(frame: CGRect(x: self.width/(spacing * 2), y: self.yPosition, width: adjustedWidth, height: image.size.height * (adjustedWidth/image.size.width)))
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
        textContent = createTextContent()
        titleText = createTitleText()
        timeText = createTimeText()
        
        addSubview(titleText)
        addSubview(timeText)
        addSubview(textContent)

        for image in displayImages {
            addSubview(image)
        }
        
    }
    
    private func createTextContent() -> UITextView{
        
        let textField = UITextView(frame: CGRect(x: width/2 - (width*3/5)/2 , y: yPosition, width: width * 3/5, height: height * 2/5))
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
        }

        return textField
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




