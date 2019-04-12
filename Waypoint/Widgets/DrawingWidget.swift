//
//  DrawingWidget.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/17/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseStorage

class DrawingWidget: UIView {

    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    public var drawingImage = UIImage.gif(name: "loading"){
        didSet{
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.alpha = 0
            }) { (true) in
                self.imageView.image = self.drawingImage
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1
                }
            }
            
        }
    }
    
    
    
    private lazy var imageView = createImageView()
   
    private lazy var shadow = createShadow()
    
    
   
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(imageView)
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
    
    private func createImageView() -> UIImageView {
        let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageV.image = drawingImage
        return imageV
    }
    


}
