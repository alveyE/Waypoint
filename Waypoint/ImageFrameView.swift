//
//  ImageFrameView.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/14/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class ImageFrameView: UIView {

    let image = UIImage(named: "trees.jpg")
    
    
    
    private lazy var imageView = createCenteredImage()
    private lazy var frameCorners = createFrameCorners()
    
    lazy var width = bounds.width
    lazy var height = bounds.height
    
 
    
    override func draw(_ rect: CGRect) {
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        clipsToBounds = true
    }
    
    
    override func layoutSubviews() {
        addSubview(imageView)
        layer.addSublayer(frameCorners)
    }
    
    
    
    private func createCenteredImage() -> UIImageView {
        if let imageGiven = image {
            
            var adjustedWidth = imageGiven.size.width
            var adjustedHeight = imageGiven.size.height
          
          
            let minimumPadding = width * 2/20
            
            if adjustedWidth > adjustedHeight{
                let preAdj = adjustedWidth
                adjustedWidth = width - minimumPadding
                adjustedHeight *= adjustedWidth/preAdj
            }else {
                let preAdj = adjustedHeight
                adjustedHeight = height - minimumPadding
                adjustedWidth *= adjustedHeight/preAdj
            }
        
            
            
        let imageCentered = UIImageView(frame: CGRect(x: width/2 - adjustedWidth/2, y: height/2 - adjustedHeight/2, width: adjustedWidth, height: adjustedHeight))
            
            imageCentered.image = imageGiven
            return imageCentered
        }else{
            return UIImageView()
        }
        
    }
  
    
    
    private func createFrameCorners() -> CAShapeLayer{
        
        let triangles = CAShapeLayer()
        
        var iWidth = imageView.frame.width
        
        if imageView.frame.width > imageView.frame.height {
            iWidth = imageView.frame.height
        }
        
        let margin = iWidth/50
        
        let bottomLeftCorner = UIBezierPath()
        
        bottomLeftCorner.move(to: CGPoint(x: imageView.frame.minX - margin, y: imageView.frame.maxY - iWidth/4))
        bottomLeftCorner.addLine(to: CGPoint(x: imageView.frame.minX - margin, y: imageView.frame.maxY + margin))
        bottomLeftCorner.addLine(to: CGPoint(x: imageView.frame.minX + iWidth/4, y: imageView.frame.maxY + margin))
        bottomLeftCorner.close()
        
      
        let topRightCorner = UIBezierPath()
        
        topRightCorner.move(to: CGPoint(x: imageView.frame.maxX + margin, y: imageView.frame.minY + iWidth/4))
        topRightCorner.addLine(to: CGPoint(x: imageView.frame.maxX + margin, y: imageView.frame.minY - margin))
        topRightCorner.addLine(to: CGPoint(x: imageView.frame.maxX - iWidth/4, y: imageView.frame.minY - margin))
        topRightCorner.close()
        
        bottomLeftCorner.append(topRightCorner)
            
        triangles.path = bottomLeftCorner.cgPath
        triangles.fillColor = #colorLiteral(red: 0.277395557, green: 0.277395557, blue: 0.277395557, alpha: 1)

        triangles.shadowColor = UIColor.black.cgColor
        triangles.shadowOpacity = 0.5
        triangles.shadowOffset = CGSize.zero
        triangles.shadowRadius = 5
        
        
        
        return triangles
    }
    
    

}