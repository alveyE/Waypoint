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
    
    private var lastPoint = CGPoint.zero
    private var swiped = false
    
    private var red: CGFloat = 0.0
    private var green: CGFloat = 0.0
    private var blue: CGFloat = 0.0
    
    public var editable = true
    
    public var urlOfDrawing = ""
    
    private lazy var imageView = createImageView()
    private lazy var preDrawnImage = getPredrawnImage()
    private lazy var shadow = createShadow()
    
    
   
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        if editable {
            addSubview(imageView)
        }else if urlOfDrawing != ""{
            addSubview(preDrawnImage)
        }
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if editable {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.imageView)
        }
        }
    }
    
    func drawLine(fromPoint:CGPoint, toPoint:CGPoint){
        if editable {
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.imageView.frame.width, height: self.imageView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(5)
        context?.setStrokeColor(UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1.0).cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if editable {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.imageView)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped, editable {
            drawLine(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
    private func getPredrawnImage() -> UIImageView {
        let drawing = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        loadImage(withURL: urlOfDrawing)
        return drawing
    }
    
    private func createImageView() -> UIImageView {
        let imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        return imageV
    }
    
    private func loadImage(withURL url: String){
        let storage = Storage.storage()
        let imgadjurl = url + ".jpg"
        let reference = storage.reference(forURL: imgadjurl)
        
        reference.getData(maxSize: 2 * 1024 * 1024) { data, error in
            
            if let error = error {
                print("error \(error)")
            } else {
             
             let imageGrabbed = UIImage(data: data!) ?? UIImage()
             self.preDrawnImage.image = imageGrabbed
                
            }
        }
        
    }


}
