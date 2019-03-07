//
//  LinkWidget.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/19/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class LinkWidget: UIView {


    public var url = "https://fractyldev.com"
    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    private lazy var linkText = createLinkText()
    private lazy var shadow = createShadow()
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(linkText)
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
    
    
    private func createLinkText() -> UITextView{
        let text = UITextView(frame: CGRect(x: width/20, y: height/3, width: width - width/20, height: height/3))
        text.isEditable = false
        text.isScrollEnabled = false
        let textFont = UIFont(name: "Arial", size: 16)
        let centeredText = NSMutableParagraphStyle()
        centeredText.alignment = .center
        let attributes: [NSAttributedString.Key:Any] = [
            .font : textFont!,
            .paragraphStyle : centeredText
        ]
        let domainString: String = URL(string: url)?.host ?? url
        let linkedText = NSMutableAttributedString(string: domainString, attributes: attributes)
        let hyperlinked = linkedText.setAsLink(textToFind: domainString, linkURL: url)
        
        if hyperlinked {
            text.attributedText = NSAttributedString(attributedString: linkedText)
        }
        
        return text
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
