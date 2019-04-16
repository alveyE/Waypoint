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
    private lazy var textIcon = createIcon(imageName: "addText", iconNum: 1)
    private lazy var imageIcon = createIcon(imageName: "addImage", iconNum: 2)
    private lazy var cameraIcon = createIcon(imageName: "camera", iconNum: 3)
    private lazy var drawingIcon = createIcon(imageName: "addDrawing", iconNum: 4)
    private lazy var linkIcon = createIcon(imageName: "addLink", iconNum: 5)
    
    weak var delegate: AddWidgetViewDelegate?
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(textIcon)
        addSubview(imageIcon)
        addSubview(cameraIcon)
        addSubview(drawingIcon)
        addSubview(linkIcon)
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
    
    
    private func createIcon(imageName: String, iconNum: Int) -> UIButton {
        let icon = UIImage(named: imageName)
        
        
        let sideMargin = (width/12)
        let widthValid = (width-2*sideMargin)/5
        let heightValid = widthValid
        let topMargin = height/2 - heightValid/2
        let padding = (width - 2*sideMargin - 5*widthValid)/5
        let xPosition = sideMargin + (widthValid + padding)*(CGFloat(iconNum - 1))
        
        let iconView = UIButton(frame: CGRect(x: xPosition, y: topMargin, width: widthValid, height: heightValid))
        iconView.setImage(icon, for: UIControl.State.normal)
      //  iconView.image = icon
        if imageName == "addText" {
            iconView.addTarget(self, action: #selector(textTapped), for: .touchUpInside)
        }else if imageName == "addImage" {
            iconView.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        }else if imageName == "camera" {
            iconView.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        }else if imageName == "addDrawing" {
            iconView.addTarget(self, action: #selector(drawTapped), for: .touchUpInside)
        }else if imageName == "addLink" {
            iconView.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
        }
            
        return iconView
    }
    
    @objc private func textTapped(){
        delegate?.addText()
    }
    
    @objc private func imageTapped(){
        delegate?.addImage()
    }
    
    @objc private func cameraTapped(){
        delegate?.activateCamera()
    }
    
    @objc private func drawTapped(){
        delegate?.addDrawing()
    }
    
    @objc private func linkTapped(){
        delegate?.addLink()
    }
    
    

}


protocol AddWidgetViewDelegate: class {
    
    func addText()
    func addImage()
    func addDrawing()
    func addLink()
    func activateCamera()
    
}
