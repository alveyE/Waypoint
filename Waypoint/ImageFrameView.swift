//
//  ImageFrameView.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/14/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class ImageFrameView: UIView {
//replace trees with loading gif or something similar
    
    var image = UIImage.gif(name: "loading") {
        didSet{
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.alpha = 0
            }) { (true) in
                self.imageView.image = self.image
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1
                }
            }
            
        }
    }
    
    
    
    private lazy var imageView = createCenteredImage()
    private lazy var frameCorners = createFrameCorners()
    
    private lazy var shadow = createShadow()
    
    lazy var width = bounds.width
    lazy var height = bounds.height
 
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(imageView)
        layer.addSublayer(frameCorners)
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
    
    private func createCenteredImage() -> UIImageView {
        if let imageGiven = image {
            
            var adjustedWidth = imageGiven.size.width
            var adjustedHeight = imageGiven.size.height
          
          
            let minimumPadding = width * 2/20
            
            let preAdj = adjustedWidth
            adjustedWidth = width - minimumPadding
            adjustedHeight *= adjustedWidth/preAdj

            
            
        let imageCentered = UIImageView(frame: CGRect(x: width/2 - adjustedWidth/2, y: height/2 - adjustedHeight/2, width: adjustedWidth, height: adjustedHeight))
            
            imageCentered.image = imageGiven
            return imageCentered
        }else{
            return UIImageView()
        }
        
    }
  
    @objc private func imageTapped(){
    //    let fullScreenImage = UIView(frame: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
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
    //    triangles.fillColor = #colorLiteral(red: 0.277395557, green: 0.277395557, blue: 0.277395557, alpha: 1)
        triangles.fillColor = #colorLiteral(red: 0.1960784314, green: 0.6549019608, blue: 0.6392156863, alpha: 1)
        triangles.shadowColor = UIColor.black.cgColor
        triangles.shadowOpacity = 0.5
        triangles.shadowOffset = CGSize.zero
        triangles.shadowRadius = 5
        
        
        
        return triangles
    }
    
    

}
