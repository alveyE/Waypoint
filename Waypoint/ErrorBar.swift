//
//  ErrorBar.swift
//  Waypoint
//
//  Created by Bret Alvey on 4/22/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class ErrorBar: UIView {

    public var barColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.76953125)
    public var messageColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public var message = "No Internet Connection"
    
    private lazy var bar = createBackgroundBar()
    private lazy var errorMessage = createMessage()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        addSubview(bar)
        addSubview(errorMessage)
    }
    
    public func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
        UIView.animate(withDuration: 5, animations: {
            self.alpha = 0
        })
        
    }
    
    private func createBackgroundBar() -> UIView{
        let bar = UIView(frame: self.frame)
        bar.backgroundColor = barColor
        return bar
    }
    
    
    private func createMessage() -> UILabel {
        let text = UILabel(frame: CGRect(x: 0, y: self.frame.height/2, width: self.frame.width, height: self.frame.height/2))
        text.textColor = messageColor
        text.textAlignment = .center
        text.font = UIFont(name: "Roboto-Regular", size: self.frame.height/3)
        text.text = message
        return text
    }
    
}

