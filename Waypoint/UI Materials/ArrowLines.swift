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

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView(){
        print("setup")
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        updateLayer()
    }

 

    private func updateLayer(){
        let arrows = CAShapeLayer()
        arrows.path = createLines().cgPath
        arrows.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        arrows.fillColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        layer.addSublayer(arrows)
    }
    
    private func createLines() -> UIBezierPath {
        print("lines")
        let width = bounds.width
        let height = bounds.height
        
        let line = UIBezierPath()
        line.lineWidth = 3
        line.move(to: CGPoint(x: 0, y: 0))
        line.move(to: CGPoint(x: width, y: height/2))
        line.move(to: CGPoint(x: 0, y: height))
        line.close()
        
        return line
    }
}
