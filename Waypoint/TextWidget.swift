//
//  TextWidget.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/13/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit


@IBDesignable
class TextWidget: UIView {

    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    public var editable = true
    public var text = ""
    
    private lazy var textContent = createTextContent()
    private lazy var shadow = createShadow()
    
 
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(textContent)
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
        return boxShadow
    }
    
    let textFont = UIFont(name: "Arial", size: 16)
    private func createTextContent() -> UITextView {
        let text = UITextView(frame: CGRect(x: width/20, y: height/30, width: width - width/10, height: height - height/30))
        
        text.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        text.isEditable = editable
        text.isScrollEnabled = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.5 * (textFont?.lineHeight)!

        let attributes: [NSAttributedString.Key:Any] = [
            .font : textFont as Any,
            .paragraphStyle : paragraphStyle,
            .foregroundColor : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        ]
        let displayText = self.text
        
        let attributedText = NSAttributedString(string: displayText, attributes: attributes)
        text.attributedText = attributedText
//        text.translatesAutoresizingMaskIntoConstraints = true
//        text.sizeToFit()
        text.addSubview(createLines())
        return text
    }
    
    public var textHeight: CGFloat{
        return textContent.frame.height
    }
    
    private func createLines() -> UIView {
        let lines = UIView(frame: CGRect(x: width/20, y: height/30 + (textFont?.lineHeight)!, width: width - width/10, height: height - height/30))
        lines.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let linesNeeded = Int(height/(textFont?.lineHeight)!)
        var yPosition: CGFloat = height/30 
        for _ in 0..<linesNeeded {
            let line = UIView(frame: CGRect(x: -width/20, y: yPosition, width: width - width/10, height: 1))
            line.backgroundColor = #colorLiteral(red: 0.8667220611, green: 0.8667220611, blue: 0.8667220611, alpha: 1)
            lines.addSubview(line)
            yPosition += (textFont?.lineHeight)! + (textFont?.lineHeight)!/2
        }
    
        return lines
    }
 

}
