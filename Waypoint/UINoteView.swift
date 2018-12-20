//
//  UINoteView.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/19/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class UINoteView: UIView {

    public var editable = false
    
    private lazy var scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    private lazy var yPosition = height/30
    private lazy var padding = width/20
    private lazy var verticalPadding = height/50
    
    override func layoutSubviews() {
        addSubview(scroll)
    }
    
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        return scrollView
    }
    
    public func addTitleWidget(title: String, timeStamp: String){
        let titleWidget = TitleView()
        titleWidget.frame = CGRect(x: padding, y: yPosition, width: width - 2*padding, height: height/8)
        titleWidget.editable = editable
        titleWidget.title = title
        titleWidget.noteTimeStamp = timeStamp
        scroll.addSubview(titleWidget)
        yPosition += titleWidget.frame.height + verticalPadding
        scroll.contentSize.height += titleWidget.frame.height + verticalPadding
    }
    
    public func addTextWidget(text: String){
        let textWidget = TextWidget()
        textWidget.frame = CGRect(x: padding, y: yPosition, width: width - 2*padding, height: height * 5/24)
        textWidget.text = text
        scroll.addSubview(textWidget)
        yPosition += textWidget.frame.height + verticalPadding
        scroll.contentSize.height += textWidget.frame.height + verticalPadding
    }
    
    public func addImageWidget(image: UIImage){
        let imageWidget = ImageFrameView()
        
        var adjustedWidth = image.size.width
        var adjustedHeight = image.size.height
        
        
       let minimumPadding = (width - 2*padding) * 2/20
       // let minimumPadding: CGFloat = 0
        if adjustedWidth > adjustedHeight{
            let preAdj = adjustedWidth
            adjustedWidth = width - minimumPadding
            adjustedHeight *= adjustedWidth/preAdj
        }else {
            let preAdj = adjustedHeight
            adjustedHeight = height - minimumPadding
            adjustedWidth *= adjustedHeight/preAdj
        }
        
        imageWidget.frame = CGRect(x: padding, y: yPosition, width: width - 2*padding, height: adjustedHeight + minimumPadding/3)
        imageWidget.image = image
        scroll.addSubview(imageWidget)
        yPosition += imageWidget.frame.height + verticalPadding
        scroll.contentSize.height += imageWidget.frame.height + verticalPadding
    }
    
    

}
