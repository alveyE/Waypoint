//
//  ArrowLines.swift
//  Waypoint
//
//  Created by Bret Alvey on 8/14/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

@IBDesignable
class ArrowLines: UIView {

    
    override func draw(_ rect: CGRect) {
        backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        
        let arrow = createLines()
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).setStroke()
        arrow.stroke()
    }
 

    
    private func createLines() -> UIBezierPath {
        let width = bounds.width
        let height = bounds.height
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 0, y: 0))
        line.move(to: CGPoint(x: width, y: height/2))
        line.move(to: CGPoint(x: 0, y: height))
        
        return line
    }
}
