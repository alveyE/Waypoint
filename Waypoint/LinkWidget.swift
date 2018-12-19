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
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    override func layoutSubviews() {
        addSubview(linkText)
    }
    
    private func createLinkText() -> UILabel{
        let text = UILabel(frame: CGRect(x: width/20, y: height/3, width: width - width/20, height: height/3))

        let textFont = UIFont(name: "Arial", size: 16)
        let centeredText = NSMutableParagraphStyle()
        centeredText.alignment = .center
        let attributes: [NSAttributedString.Key:Any] = [
            .font : textFont!,
            .paragraphStyle : centeredText
        ]
        let linkedText = NSMutableAttributedString(string: url, attributes: attributes)
        let hyperlinked = linkedText.setAsLink(textToFind: url, linkURL: url)
        
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
