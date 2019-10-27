//
//  ImageFullScreen.swift
//  Waypoint
//
//  Created by Bret Alvey on 3/12/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class ImageFullScreen: UIView {

    private lazy var pan = createScroll()
    public var image = UIImageView() {
        didSet{
            image.frame = CGRect(x: 0, y: (self.bounds.height/2) - (image.frame.height/2), width: image.frame.width, height: image.frame.height)
            layoutSubviews()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
        pan.addSubview(image)
        addSubview(pan)
    }
    
    private func createScroll() -> UIScrollView{
        let scroll = UIScrollView(frame: self.bounds)
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }
    
    

}
