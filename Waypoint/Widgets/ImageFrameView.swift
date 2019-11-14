//
//  ImageFrameView.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/14/18.
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
                self.hasChanged = true
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1
                }
            }
            
        }
    }
    
    
    private var hasChanged = false
    private lazy var imageView = createCenteredImage()
    private lazy var frameCorners = createFrameCorners()
    private lazy var deleteIcon = createDeleteIcon()
    private lazy var shadow = createShadow()
    
    lazy var width = bounds.width
    lazy var height = bounds.height
    
    public var imageWidth: CGFloat = 0
    public var imageHeight: CGFloat = 0
    public var canDelete = false
    public weak var delegate: ImageFrameViewDelegate?
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(imageView)
        if canDelete{
            addSubview(deleteIcon)
        }
      //  layer.addSublayer(frameCorners)
    }
    
  
    private func createShadow() -> CAShapeLayer {
        let box = UIBezierPath(rect: CGRect(x: bounds.minX, y: bounds.minY, width: width, height: height))
        let boxShadow = CAShapeLayer()
        boxShadow.path = box.cgPath
        boxShadow.shadowColor = UIColor.black.cgColor
        boxShadow.shadowOpacity = 0.25
        boxShadow.shadowOffset = CGSize.zero
        boxShadow.shadowRadius = 5
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                boxShadow.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                boxShadow.fillColor = #colorLiteral(red: 0.1725495458, green: 0.1713090837, blue: 0.1735036671, alpha: 1)
            }
        } else {
            boxShadow.fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        return boxShadow
    }
    
    private func createCenteredImage() -> UIImageView {
        if let imageGiven = image {
            
            
            var adjustedWidth = imageWidth
            var adjustedHeight = imageHeight
            if adjustedWidth == 0 {
                adjustedWidth = 1
            }
          
            let minimumPadding = width * 2/20
            
            let preAdj = adjustedWidth
            adjustedWidth = width - minimumPadding
            adjustedHeight *= adjustedWidth/preAdj

            
            
        let imageCentered = UIImageView(frame: CGRect(x: width/2 - adjustedWidth/2, y: height/2 - adjustedHeight/2, width: adjustedWidth, height: adjustedHeight))
        
            imageCentered.image = imageGiven
            imageCentered.isUserInteractionEnabled = true
            let iTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageCentered.addGestureRecognizer(iTap)
      
            if !hasChanged {
               // image
                imageCentered.contentMode = .scaleAspectFit
            }
            
            return imageCentered
        }else{
            return UIImageView()
        }
        
    }
  
    @objc private func imageTapped(){
        if hasChanged {
        delegate?.displayImage(image: image!)
        }
    }
    private func createDeleteIcon() -> UIButton{
        let iconWidth = width/10
        
        let deleteButton = UIButton(frame: CGRect(x:  iconWidth * -1/4, y: iconWidth * -1/4, width: iconWidth, height: iconWidth))
        deleteButton.setImage(UIImage(named: "delete"), for: UIControl.State.normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return deleteButton
    }
    
    @objc func deleteTapped(){
        delegate?.deleteWidget(self)
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


protocol ImageFrameViewDelegate: class {
    
    func displayImage(image: UIImage)
    func deleteWidget(_ widget: UIView)
}
