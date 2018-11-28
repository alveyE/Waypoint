//
//  NoteView.swift
//  Bulletin
//
//  Created by Ethan Alvey on 11/15/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class NoteView: UIView {
    
    var width: CGFloat = 0
    var height: CGFloat = 0
    
//    public var noteColor = #colorLiteral(red: 1, green: 0.9390159597, blue: 0.5017074679, alpha: 1) {
//        didSet{
//            setNeedsDisplay()
//            setNeedsLayout()
//        }
//    }
//    public var foldColor = #colorLiteral(red: 1, green: 0.8700071168, blue: 0.2975686683, alpha: 1)
    public var noteColor = #colorLiteral(red: 1, green: 0.9230569365, blue: 0.3114053169, alpha: 1) {
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var foldColor = #colorLiteral(red: 1, green: 0.8495431358, blue: 0.1709763357, alpha: 1)
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

    
    
    lazy var textContent = UITextView(frame: CGRect(x: width/2 - (width*3/5)/2 , y: width/10, width: width * 3/5, height: height * 2/5))
    
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
        
        
        noteColor.setFill()
        outlinePath.fill()
        foldColor.setFill()
        triangleFold.fill()
        titleBar.fill()
        textContent.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        textContent.font = UIFont(name: "Marker Felt", size: 30)
        textContent.textAlignment = .center
        
        
        if attributedText != nil {
        textContent.attributedText = attributedText
        }else{
        textContent.text = text
        }
        print(textContent.text)
        textContent.textColor = textColor
        
        addSubview(textContent)
        for img in imageDisplay {
            let displayedImage = UIImageView(frame: CGRect(x: width/2 - (img.size.width/2), y: textContent.frame.maxY + height/25, width: img.size.width, height: img.size.height))
            displayedImage.image = img
            addSubview(displayedImage)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    public func setText(to text: String){
        textContent.text = text
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
