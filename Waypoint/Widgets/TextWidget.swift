//
//  TextWidget.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/13/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit


@IBDesignable
class TextWidget: UIView {

    private var width: CGFloat{
        return bounds.width
    }
    private var height: CGFloat{
       return bounds.height
    }
    
    public var editable = true
    public var text = ""
    
    public lazy var textContent = createTextContent()
    private lazy var shadow = createShadow()
    private lazy var deleteIcon = createDeleteIcon()
    
    public var noteID = ""
    public weak var delegate: TextWidgetDelegate?
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(textContent)
        if editable{
        addSubview(deleteIcon)
        }
    }
    
    public func addLine(adding: Bool) -> CGFloat{
        let preHeight = frame.height
        var lineHeight = (textFont?.lineHeight)! + (textFont?.lineHeight)!/2
        if !adding {
            lineHeight *= -1
        }
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.frame.height + lineHeight)
            let postHeight = self.frame.height
            let heightDifference = postHeight - preHeight
            self.shadow.removeFromSuperlayer()
            self.shadow = self.createShadow()
            self.textContent.frame = CGRect(x: self.textContent.frame.minX, y: self.textContent.frame.minY, width: self.textContent.frame.width, height: self.textContent.frame.height + heightDifference)
            
        }
        
        setNeedsLayout()
        setNeedsDisplay()
        return lineHeight
    }
    
    public func fitText(){
        let newSize = textContent.sizeThatFits(CGSize(width: textContent.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let recommendedHeight = newSize.height
        while textContent.frame.height < recommendedHeight {
            let _ = addLine(adding: true)
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
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                boxShadow.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                boxShadow.fillColor = #colorLiteral(red: 0.1725495458, green: 0.1713090837, blue: 0.1735036671, alpha: 1)
            }
        } else {
            boxShadow.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        return boxShadow
    }
    
    let textFont = UIFont(name: "Roboto-Regular", size: 16)
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
        if self.text == "" {
            text.attributedText = NSAttributedString(string: " ", attributes: attributes)
            text.attributedText = NSAttributedString(string: "")
        }
        let displayText = self.text
        
        let attributedText = NSAttributedString(string: displayText, attributes: attributes)
        text.attributedText = attributedText
        if editable {
            let tap = UITapGestureRecognizer(target: self, action: #selector(activateEditing))
            text.addGestureRecognizer(tap)
        }
        text.addSubview(createLines())
        
        return text
    }
    
    
    @objc private func activateEditing(){
        textContent.becomeFirstResponder()
    }
    
    
    public var textHeight: CGFloat{
        return textContent.frame.height
    }
    
    private func createDeleteIcon() -> UIButton{
        let iconWidth = width/10
        
        let deleteButton = UIButton(frame: CGRect(x:  iconWidth * -1/4, y: iconWidth * -1/4, width: iconWidth, height: iconWidth))
        deleteButton.setImage(UIImage(named: "delete"), for: UIControl.State.normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return deleteButton
    }
    
    @objc func deleteTapped(){
        delegate?.deleteWidget(self)
    }
    
    private func createLines() -> UIView {
        let lines = UIView(frame: CGRect(x: width/20, y: height/30 + (textFont?.lineHeight)!, width: width - width/10, height: height - height/30))
        lines.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let linesNeeded = Int(height/(textFont?.lineHeight)!)*100
        var yPosition: CGFloat = height/30 
        for _ in 0..<linesNeeded {
            let line = UIView(frame: CGRect(x: -width/20, y: yPosition, width: width - width/10, height: 1))
            
            if #available(iOS 12.0, *) {
                       if traitCollection.userInterfaceStyle == .light {
                          line.backgroundColor = #colorLiteral(red: 0.8667220611, green: 0.8667220611, blue: 0.8667220611, alpha: 1)
                       }else{
                           line.backgroundColor = #colorLiteral(red: 0.1224855259, green: 0.1225136295, blue: 0.1224818304, alpha: 1)
                       }
                   } else {
                       line.backgroundColor = #colorLiteral(red: 0.8667220611, green: 0.8667220611, blue: 0.8667220611, alpha: 1)
                   }
            
            lines.addSubview(line)
            yPosition += (textFont?.lineHeight)! + (textFont?.lineHeight)!/2
        }
    
        return lines
    }
 

}


protocol TextWidgetDelegate: class{
    func deleteWidget(_ widget: UIView)
}
