//
//  NoteView.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class NoteView: UIView {
    
    var width: CGFloat = 0
    var height: CGFloat = 0
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
    public var textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1) {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var text = "Enter Text Here" {
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
    var imageDisplay: [UIImage] = [] {
        didSet{
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
    private var hasDrawn = false;

    
    
    
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
        let triangleShape = CAShapeLayer()
        
        triangleShape.path = triangleFold.cgPath
        triangleShape.fillColor = foldColor.cgColor
        triangleShape.shadowColor = UIColor.black.cgColor
        triangleShape.shadowOpacity = 0.5
        triangleShape.shadowOffset = CGSize.zero
        triangleShape.shadowRadius = 5
        
        layer.addSublayer(triangleShape)
        }
        var yPosition = width/10
        if text != "" {
         let textContent = UITextView(frame: CGRect(x: width/2 - (width*3/5)/2 , y: yPosition, width: width * 3/5, height: height * 2/5))
        
        textContent.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        textContent.font = UIFont(name: "Marker Felt", size: 30)
        textContent.textAlignment = .center
        
        
        if attributedText != nil {
        textContent.attributedText = attributedText
        }else{
        textContent.text = text
        }
        textContent.textColor = textColor
        
        addSubview(textContent)
        yPosition += textContent.frame.height + height/25
        }
        for img in imageDisplay {
            let displayedImage = UIImageView(frame: CGRect(x: width/2 - (img.size.width/2), y: yPosition, width: img.size.width, height: img.size.height))
            displayedImage.image = img
            addSubview(displayedImage)
            yPosition += displayedImage.frame.height + height/25
        }
        hasDrawn = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    public func setText(to text: String){
        self.text = text
    }
    
    public func addImage(_ imageAdding: UIImage){
        imageDisplay.append(imageAdding)
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
        text = ""
        link = ("","")
        attributedText = nil
        imageDisplay = []
        subviews.forEach({ $0.removeFromSuperview() })
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
