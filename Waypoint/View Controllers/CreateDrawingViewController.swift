//
//  ViewController.swift
//  DrawingTestApp
//
//  Created by Carson Cramer on 12/5/18.
//  Copyright © 2018 Carson Cramer. All rights reserved.
//

import UIKit

class CreateDrawingViewController: UIViewController {
 
    var lastPoint = CGPoint.zero
    var swiped = false
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0

    @IBOutlet var arrayOfButtons: [UIButton]!
    
    @IBAction func colorPicked(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            (red,green,blue) = (0,0,0)
        case 1:
            (red,green,blue) = (1,0,0)
        case 2:
            (red,green,blue) = (1,0.533,0)
        case 3:
            (red,green,blue) = (1,0.941,0)
        case 4:
            (red,green,blue) = (0,1,0)
        case 5:
            (red,green,blue) = (0,0,1)
        case 6:
            (red,green,blue) = (0.741,0,1)
        case 7:
            (red,green,blue) = (1,1,1)
            
        default:
            break
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.imageView)
        }
    }
    
    func drawLine(fromPoint:CGPoint, toPoint:CGPoint){
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
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.imageView)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLine(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }
    
    
    @IBAction func resetButton(_ sender: Any) {
        self.imageView.image = nil
    }
    
    func completedDrawing(){
        //push and return image
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
}

extension UIImage {
    
    var jpegDrawingRepresentation : Data? {
        return self.jpegData(compressionQuality: 0.65)
    }
}
