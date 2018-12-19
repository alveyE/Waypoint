//
//  TitleView.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/13/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

@IBDesignable
class TitleView: UIView {

    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    public var editable = false

    private lazy var titleText = createTitleText()
    private lazy var timeStamp = createTimeStamp()
    private lazy var saveButton = createSaveButton()
    override func draw(_ rect: CGRect) {

//        let box = UIBezierPath(rect: CGRect(x: bounds.minX, y: bounds.minY, width: width, height: height))
//        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill()
//        box.fill()
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
 
    override func layoutSubviews() {
        addSubview(titleText)
        addSubview(timeStamp)
        addSubview(saveButton)
    }
    
    
    private func createTitleText() -> UITextView {
        let title = UITextView(frame: CGRect(x: width/25, y: height/50, width: width * 8/9, height: height * 3/8))
        title.isEditable = editable
        title.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        title.isScrollEnabled = false
        let titleFont = UIFont(name: "Arial-BoldMT", size: 20)
        title.font = titleFont
        title.text = "Note Title Here"
        
        
        return title
        
    }
    
    
    private func createTimeStamp() -> UILabel {
        let time = UILabel(frame: CGRect(x: width/8, y: height * 7/24, width: width * 7/9, height: height/4))
        time.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let dateFont = UIFont(name: "Arial", size: 18)
        let timeFont = UIFont(name: "Arial-ItalicMT", size: 18)
        time.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        time.font = timeFont
        let dateText = "Dec. 13, 2018 - "
        let timeText = "8:35am"
        let attributedTime = NSMutableAttributedString(string: dateText, attributes: [.font : dateFont as Any])
        attributedTime.append(NSAttributedString(string: timeText, attributes: [.font : timeFont as Any]))
        time.attributedText = attributedTime
        return time
    }
    
    private func createSaveButton() -> UIButton {
        let save = UIButton(frame: CGRect(x: width * 17/20, y: height/9, width: width/10, height: width/10))
        let saveImage = UIImage(named: "tag")
        save.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        save.setImage(saveImage, for: UIControl.State.normal)
        return save
        
        
    }
    

}