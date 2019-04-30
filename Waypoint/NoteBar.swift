//
//  NoteBar.swift
//  Waypoint
//
//  Created by Bret Alvey on 4/30/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class NoteBar: UIView {

    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
  //  private lazy var shadow = createShadow()
    
   
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 0)
        let border = outlinePath()
        
        #colorLiteral(red: 0.9137254902, green: 0.9058823529, blue: 0.8117647059, alpha: 1).setFill()
        border.fill()
       
    }
    
    private func outlinePath() -> UIBezierPath{
        let inwardCut = width/50
        
        let outlinePath = UIBezierPath()
        outlinePath.move(to: CGPoint(x: 0, y: height))
        outlinePath.addLine(to: CGPoint(x: inwardCut, y: 0))
        outlinePath.addLine(to: CGPoint(x: width - inwardCut, y: 0))
        outlinePath.addLine(to: CGPoint(x: width, y: height))
        outlinePath.addLine(to: CGPoint(x: 0, y: height))
        return outlinePath
    }
    
    
    private func createShadow() -> CAShapeLayer {
        let box = outlinePath()
        let boxShadow = CAShapeLayer()
        boxShadow.path = box.cgPath
        boxShadow.shadowColor = UIColor.black.cgColor
        boxShadow.shadowOpacity = 0.25
        boxShadow.shadowOffset = CGSize.zero
        boxShadow.shadowRadius = 5
        boxShadow.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        boxShadow.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)

        return boxShadow
    }
 

}
