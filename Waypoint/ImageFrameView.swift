//
//  ImageFrameView.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/14/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class ImageFrameView: UIView {

    let image = UIImage(named: "kenya.jpeg")
    lazy var imageView = createCenteredImage()
    
    lazy var width = bounds.width
    lazy var height = bounds.height
    
    
    
    override func draw(_ rect: CGRect) {
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createFrameCorners()
        
    }
    
    
    override func layoutSubviews() {
        addSubview(imageView)
    //    createFrameCorners()
        
    }
    
    
    
    private func createCenteredImage() -> UIImageView {
        if let imageGiven = image {
            
            var adjustedWidth = imageGiven.size.width
            var adjustedHeight = imageGiven.size.height
          
            
            if adjustedWidth > width - width/10{
                let preAdj = adjustedWidth
                adjustedWidth = width - width/10
                adjustedHeight *= adjustedWidth/preAdj
            }
            
            if adjustedHeight > height - height/10 {
                let preAdj = adjustedHeight
                adjustedHeight = height - height/10
                adjustedWidth *= adjustedHeight/preAdj
            }
            
            
            
        let imageCentered = UIImageView(frame: CGRect(x: width/2 - adjustedWidth/2, y: height/2 - adjustedHeight/2, width: adjustedWidth, height: adjustedHeight))
            
            imageCentered.image = imageGiven
            return imageCentered
        }else{
            return UIImageView()
        }
        
    }
  
    
    
    private func createFrameCorners(){
        
        
        if let img = image {
        
        let iWidth = img.size.width
        let iHeight = img.size.height
            
        let bottomLeftCorner = UIBezierPath()
        
        bottomLeftCorner.move(to: CGPoint(x: imageView.frame.minX - iWidth/8, y: imageView.frame.maxY - iWidth/4))
        bottomLeftCorner.addLine(to: CGPoint(x: imageView.frame.minX - iWidth/8, y: imageView.frame.maxY + iWidth/8))
        bottomLeftCorner.addLine(to: CGPoint(x: imageView.frame.minX + iWidth/4, y: imageView.frame.maxY + iWidth/8))
        bottomLeftCorner.close()
        
      
        let topRightCorner = UIBezierPath()
        
        topRightCorner.move(to: CGPoint(x: imageView.frame.maxX + iWidth/8, y: imageView.frame.minY + iWidth/4))
        topRightCorner.addLine(to: CGPoint(x: imageView.frame.maxX + iWidth/8, y: imageView.frame.minY - iWidth/8))
        topRightCorner.addLine(to: CGPoint(x: imageView.frame.maxX - iWidth/4, y: imageView.frame.minY - iWidth/8))
        topRightCorner.close()
        
        
        
        
        
        
        
        #colorLiteral(red: 0.2162140839, green: 1, blue: 0.7142448477, alpha: 1).setFill()
        bottomLeftCorner.fill()
        topRightCorner.fill()
        
        }
        
        
    }
    
    

}
