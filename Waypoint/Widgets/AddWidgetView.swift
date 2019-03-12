//
//  AddWidgetView.swift
//  Waypoint
//
//  Created by Bret Alvey on 3/12/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class AddWidgetView: UIView {

    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    private lazy var shadow = createShadow()
    private lazy var textIcon = createIcon(imageName: "text", iconNum: 1)
    private lazy var imageIcon = createIcon(imageName: "image", iconNum: 2)
    private lazy var drawingIcon = createIcon(imageName: "drawing", iconNum: 3)
    private lazy var linkIcon = createIcon(imageName: "link", iconNum: 4)
    
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
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
    
    
    private func createIcon(imageName: String, iconNum: Int) -> UIImageView {
        let icon = UIImage(named: imageName)
        
        let sideMargin = (width/12) * CGFloat(iconNum)
        let topMargin = height/8
        let padding = width/14
        let widthValid = (width - (sideMargin * 2) - padding)/4
        let heightValid = height - topMargin*2
        
        let iconView = UIImageView(frame: CGRect(x: sideMargin, y: topMargin, width: widthValid, height: heightValid))
        iconView.image = icon
        
        return iconView
    }

}
