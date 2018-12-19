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
    
    
    private lazy var textContent = createTextContent()
    
    
    override func draw(_ rect: CGRect) {
        
//        let box = UIBezierPath(rect: CGRect(x: bounds.minX, y: bounds.minY, width: width, height: height))
//        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill()
//        box.fill()
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
    }
    
    override func layoutSubviews() {
        addSubview(textContent)
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
        let displayText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        
        let attributedText = NSAttributedString(string: displayText, attributes: attributes)
        text.attributedText = attributedText
        text.addSubview(createLines())
        return text
    }
    
    
    private func createLines() -> UIView {
        let lines = UIView(frame: CGRect(x: width/20, y: height/30 + (textFont?.lineHeight)!, width: width - width/10, height: height - height/30))
        lines.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let linesNeeded = Int(height/(textFont?.lineHeight)!)
        var yPosition: CGFloat = 0
        for _ in 0..<linesNeeded {
            let line = UIView(frame: CGRect(x: -width/20, y: yPosition, width: width - width/10, height: 1))
            line.backgroundColor = #colorLiteral(red: 0.8667220611, green: 0.8667220611, blue: 0.8667220611, alpha: 1)
            lines.addSubview(line)
            yPosition += (textFont?.lineHeight)! + (textFont?.lineHeight)!/2
        }
    
        return lines
    }
 

}