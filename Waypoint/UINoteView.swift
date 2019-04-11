//
//  UINoteView.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/19/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseStorage


class UINoteView: UIView, UITextViewDelegate {
    
    public var editable = false
    public var hasSaveButton = false
    public var hasCalanderIcon = true
    public var noteID = ""
    public var saved = false
    public var endYPositions = [CGFloat]()
    public var widgetAdderY: CGFloat = 0
    public var hasRefresh = false
    
    private lazy var scroll = createScrollView()
    
    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    private lazy var yPosition = height/15
    private lazy var padding = width/20
    private lazy var verticalPadding = height/50
    private var animationTime: TimeInterval = 0.3
    
    private var tapGestures: [UITapGestureRecognizer] = []
    private let noteTap = UITapGestureRecognizer(target: self, action: #selector(doNothing))
   
    weak var delegate: UINoteViewDelegate?
    
    override func layoutSubviews() {
        addSubview(scroll)
    }
    
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        scrollView.showsVerticalScrollIndicator = false
        if hasRefresh {
        scrollView.addSubview(refresh)
        }
        return scrollView
    }
    
    
    private var refresh: UIRefreshControl {
        let ref = UIRefreshControl()
        ref.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return ref
    }
    
    
    
    @objc private func handleRefresh(_ control: UIRefreshControl){
        delegate?.refreshPulled()
        control.endRefreshing()
    }
    public func addTitleWidget(title: String, timeStamp: String, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0

        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
            let titleWidget = TitleView()
            titleWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width/4)
            titleWidget.editable = editable
            titleWidget.hasSaveButton = hasSaveButton
            titleWidget.hasCalanderIcon = hasCalanderIcon
            titleWidget.noteID = noteID
            titleWidget.saved = saved
            titleWidget.title = title
            titleWidget.noteTimeStamp = timeStamp
            titleWidget.alpha = 0

            self.scroll.addSubview(titleWidget)
         //   stack.addArrangedSubview(titleWidget)
        
        UIView.animate(withDuration: animationTime) {
            titleWidget.alpha = 1

        }
        
        
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
            titleWidget.addGestureRecognizer(tap)
        
            tapGestures.append(tap)
            endYPositions.append(titleWidget.frame.maxY)
        
        if yPlacement == nil {
            yPosition += titleWidget.frame.height + verticalPadding
           // scroll.contentSize.height += (titleWidget.frame.height + verticalPadding)
        }
        adjustScroll()
    }
    
    public func addTextWidget(text: String, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        let textFont = UIFont(name: "Helvetica Neue", size: 16)
    
        
            let textWidget = TextWidget()
            textWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width * 17/48)
            textWidget.editable = editable
            textWidget.text = text
            textWidget.alpha = 0
            scroll.addSubview(textWidget)
        UIView.animate(withDuration: animationTime) {
            textWidget.alpha = 1
            
        }
        
        if yPlacement == nil {
            yPosition += textWidget.frame.height + verticalPadding
         //   scroll.contentSize.height += textWidget.frame.height + verticalPadding
        }
                textWidget.textContent.delegate = self
        textWidget.addGestureRecognizer(noteTap)
        adjustScroll()
    }
    
    public func addImageWidget(imageURL: String, imageWidth: CGFloat, imageHeight: CGFloat, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        
        let storage = Storage.storage()
        let imgadjurl = imageURL + ".jpg"
        let reference = storage.reference(forURL: imgadjurl)
        
        let imageWidget = ImageFrameView()
        imageWidget.alpha = 0
        
        imageWidget.imageWidth = imageWidth
        imageWidget.imageHeight = imageHeight
        
        var adjustedWidth = imageWidth
        var adjustedHeight = imageHeight
        
        
        let minimumPadding = (self.width - 2*self.padding) * 2/20
        
        let preAdj = adjustedWidth
        adjustedWidth = self.width - minimumPadding
        adjustedHeight *= adjustedWidth/preAdj
        
        
        imageWidget.frame = CGRect(x: self.padding, y: verticalPlacing, width: self.width - 2*self.padding, height: adjustedHeight)
        
        reference.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            let image = UIImage(data: data!) ?? UIImage()
            
            
            imageWidget.image = image
//
//            imageWidget.alpha = 0
//
//            UIView.transition(with: imageWidget, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//                imageWidget.alpha = 1
//            }, completion: nil)
            
           
        })
        self.scroll.addSubview(imageWidget)
        UIView.animate(withDuration: animationTime) {
            imageWidget.alpha = 1
            
        }
        
        if yPlacement == nil {
            self.yPosition += imageWidget.frame.height + self.verticalPadding
        //    self.scroll.contentSize.height += imageWidget.frame.height + self.verticalPadding
            }
        imageWidget.addGestureRecognizer(noteTap)
        adjustScroll()
    }
    
    public func addImageWidget(image: UIImage, imageWidth: CGFloat, imageHeight: CGFloat, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        
    
        let imageWidget = ImageFrameView()
        imageWidget.alpha = 0
        
        imageWidget.imageWidth = imageWidth
        imageWidget.imageHeight = imageHeight
        
        var adjustedWidth = imageWidth
        var adjustedHeight = imageHeight
        
        
        let minimumPadding = (self.width - 2*self.padding) * 2/20
        
        let preAdj = adjustedWidth
        adjustedWidth = self.width - minimumPadding
        adjustedHeight *= adjustedWidth/preAdj
        
        
        imageWidget.frame = CGRect(x: self.padding, y: verticalPlacing, width: self.width - 2*self.padding, height: adjustedHeight)
        imageWidget.image = image

        self.scroll.addSubview(imageWidget)
        UIView.animate(withDuration: animationTime) {
            imageWidget.alpha = 1
            
        }
        
        if yPlacement == nil {
            self.yPosition += imageWidget.frame.height + self.verticalPadding
         //   self.scroll.contentSize.height += imageWidget.frame.height + self.verticalPadding
        }
        imageWidget.addGestureRecognizer(noteTap)
        adjustScroll()
    }
    
    
    
    public func addLinkWidget(url: String, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        
        let linkWidget = LinkWidget()
        linkWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width * 6/20)
        linkWidget.url = url
        linkWidget.editable = editable
        scroll.addSubview(linkWidget)
        if yPlacement == nil {
        yPosition += linkWidget.frame.height + verticalPadding
       // scroll.contentSize.height += linkWidget.frame.height + verticalPadding
        }
        adjustScroll()
        linkWidget.addGestureRecognizer(noteTap)
    }
    
    public func addDrawingWidget(setImage: String, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        
        let drawingWidget = DrawingWidget()
        drawingWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width * 2/5)
        
        drawingWidget.urlOfDrawing = setImage
        
        scroll.addSubview(drawingWidget)
        if yPlacement == nil {
        yPosition += drawingWidget.frame.height + verticalPadding
        }
      //scroll.contentSize.height += drawingWidget.frame.height + verticalPadding
        adjustScroll()
        drawingWidget.addGestureRecognizer(noteTap)
    }
    
    public func addWidgetMaker(yPlacement: CGFloat?, adderDelegate: AddWidgetViewDelegate){
        var verticalPlacing: CGFloat = 0
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        let widgetAdder = AddWidgetView(frame: CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width/4))
        
        scroll.addSubview(widgetAdder)
        if yPlacement == nil {
            yPosition += widgetAdder.frame.height + verticalPadding
        }
        widgetAdder.delegate = adderDelegate
        
      //  scroll.contentSize.height += widgetAdder.frame.height + verticalPadding
        adjustScroll()
        widgetAdderY = widgetAdder.frame.minY
    }
    
    @objc private func titleTapped(_ sender: Any){
    
        if let titleTouched = sender as? UITapGestureRecognizer {
            if let index = tapGestures.index(of: titleTouched) {
            delegate?.touchHeard(onIndex: index)
            }else{
                print("Error title tap not in taps array")
            }
        }
    }
 
    private func adjustScroll(){
        var contentRect = CGRect.zero
        
        for view in scroll.subviews {
            contentRect = contentRect.union(view.frame)
        }
        scroll.contentSize.height = contentRect.size.height
        if scroll.contentSize.height < height {
            scroll.contentSize.height = height + 1
        }
    }
    
    
    public func moveWidgets(overY setY: CGFloat, by amnt: CGFloat, down: Bool){
        var moveAmnt = amnt
        if !down {
            moveAmnt *= -1
        }
        
        for sub in scroll.subviews {
            if sub.frame.minY > setY {
                UIView.animateKeyframes(withDuration: animationTime, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
                    
                    sub.frame.origin.y += moveAmnt

                },completion: nil)
                
            }
            
        }
        UIView.animate(withDuration: animationTime) {
            //self.scroll.contentSize.height += moveAmnt
            self.adjustScroll()
        }
        
        for index in endYPositions.indices {
            if endYPositions[index] - (calculateHeight(of: "title", includePadding: false)) > setY {
                endYPositions[index] += moveAmnt
            }
        }
        if widgetAdderY > setY {
            widgetAdderY += moveAmnt
        }
        
    }
    
    public func removeWidgetsInRange(minY: CGFloat, maxY: CGFloat?){
        for sub in scroll.subviews {
            var meetsMaxReq = true
            if let maxVal = maxY {
                if !(sub.frame.maxY < maxVal) {
                    meetsMaxReq = false
                }
            }
            
            if sub.frame.minY > minY, meetsMaxReq {
                
                if let title = sub as? TitleView {
                    for tap in tapGestures {
                        if (title.gestureRecognizers?.contains(tap))!{
                            if let indexOfTap = tapGestures.index(of: tap) {
                            tapGestures.remove(at: indexOfTap)
                            endYPositions.remove(at: indexOfTap)
                            }
                        }
                    }
//                    endYPositions = []
//                    var sortedCopy = scroll.subviews
//                    sortedCopy.sort(by: {$0.frame.minY < $1.frame.minY})
//                    for possibleTitle in sortedCopy {
//                        if let otherTitle = possibleTitle as? TitleView{
//                            endYPositions.append(otherTitle.frame.maxY)
//                        }
//                    }
                }
                
                sub.removeFromSuperview()
            }
            
        }
        adjustScroll()
    }
    
    public func nextYmax(overY yVal: CGFloat) -> CGFloat {
//        var val: CGFloat = 0
        var savedSub = UIView()
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        
        for sub in subCopy {
            if sub.frame.minY > yVal {
            
            if let _ = sub as? TitleView {
                break
            }else {
                savedSub = sub
            }
            }
        }
        
        
        
        return savedSub.frame.maxY
    }
    
    public func listOfWidgets() -> [String]{
        var widgets = [String]()
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        
        for sub in subCopy {
            if let _ = sub as? TitleView {
                widgets.append("title")
            }else if let _ = sub as? TextWidget {
                widgets.append("text")
            }else if let _ = sub as? ImageFrameView {
                widgets.append("image")
            }else if let _ = sub as? LinkWidget {
                widgets.append("link")
            }else if let _ = sub as? DrawingWidget {
                widgets.append("drawing")
            }
        }
        
        return widgets
    }
    
    public func listOfText() -> [String] {
        var textWritten = [String]()
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        
         for sub in subCopy {
            if let textWidget = sub as? TextWidget {
                textWritten.append(textWidget.textContent.text)
            }
        }
        return textWritten
    }
    
    public func listOfLinks() -> [String] {
        var links = [String]()
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        
        for sub in subCopy {
            if let linkWidget = sub as? LinkWidget {
                links.append(linkWidget.linkText.text ?? "")
            }
        }
        return links
    }
    
    public func titleText() -> String {
        var titleText = ""
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        
        for sub in subCopy {
            if let title = sub as? TitleView {
                titleText = title.titleText.text ?? ""
            }
        }
        return titleText
    }
    
    
    public func calculateHeight(of widgetType: String, includePadding: Bool) -> CGFloat{
        var heightCalc: CGFloat = 0
        if widgetType == "title" {
            heightCalc =  width/4
        }else if widgetType == "text" {
            heightCalc = width * 17/48
        }else if widgetType == "drawing" {
            heightCalc =  width * 2/5
        }else if widgetType == "link" {
            heightCalc = width * 6/20
        }
        if includePadding {
            return heightCalc + verticalPadding
        }else{
            return heightCalc
        }
    }
    
    public func calculateHeight(imageWidth: CGFloat, imageHeight: CGFloat, includePadding: Bool) -> CGFloat {
        var adjustedWidth = imageWidth
        var adjustedHeight = imageHeight
        
        
        let minimumPadding = (self.width - 2*self.padding) * 2/20
        
        let preAdj = adjustedWidth
        adjustedWidth = self.width - minimumPadding
        adjustedHeight *= adjustedWidth/preAdj
        
        if includePadding {
            return adjustedHeight + verticalPadding
        }else{
            return adjustedHeight
        }
    }
    
    public func clearNote(){
        scroll.subviews.forEach({$0.removeFromSuperview()})
        scroll.contentSize.height = height
        yPosition = height/15
        endYPositions = []
        tapGestures = []
    }
    
    public func cleanClear(){
        removeWidgetsInRange(minY: 0, maxY: nil)
        yPosition = height/15
    }
    
    
    public func getPadding() -> CGFloat {
        return verticalPadding
    }
    
    public func getScrollMax() -> CGFloat {
        return scroll.contentSize.height
    }
    
    public func getLastElementMax() -> CGFloat {
        var maxSubY = scroll.subviews.first?.frame.maxY ?? 0
        for sub in scroll.subviews {
            if sub.frame.maxY > maxSubY {
                maxSubY = sub.frame.maxY
            }
        }
        return maxSubY
        
    }
    private func leway() -> CGFloat {
        return width/4
    }
    
    private func getTopMinY() -> CGFloat {
     
        var top: CGFloat = scroll.subviews.first?.frame.minY ?? 0
    
        for sub in scroll.subviews {
            if sub.frame.minY < top {
                top = sub.frame.minY
            }
        }
        
        
        return top
    }
    
    @objc private func doNothing(){
        delegate?.doNothing()
    }
    
    private func getBottomMaxY() -> CGFloat {
        
        var bottom: CGFloat = scroll.subviews.first?.frame.maxY ?? 0
        
        for sub in scroll.subviews {
            if sub.frame.minY > bottom {
                bottom = sub.frame.maxY
            }
        }

        return bottom
    }
    
    public func hide(){
        UIView.animate(withDuration: animationTime) {
            self.alpha = 0
        }
//        UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: {
//
//        }, completion: nil)

    }
    
    public func unHide(){
               self.alpha = 1
        
    }
    
    public func trimExcess(){
        scroll.contentSize.height -= height
        scroll.contentSize.height += width/4
    }
    
    
    public func correctScroll(){
        let scrollAmnt = getBottomMaxY() - getTopMinY() + leway()
        scroll.contentSize.height = scrollAmnt
    }
    public func increaseScrollSlack(by amnt: CGFloat){
        scroll.contentSize.height += amnt
    }
    
    
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//
//
//        let initialHeight = textView.frame.height
//        let adjustedSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat(MAXFLOAT)))
//        let afterHeight = adjustedSize.height
//        let difference = afterHeight - initialHeight
//        if let textWidget = textView.superview {
//            textView.superview!.frame.size = CGSize(width: textWidget.frame.width, height: textWidget.frame.height + difference)
//
//            textView.frame.size = adjustedSize
//            for widget in subviews {
//                if widget.frame.minY > textView.frame.minY {
//                    widget.frame = CGRect(x: widget.frame.minX, y: widget.frame.minY + difference, width: widget.frame.width, height: widget.frame.height)
//                }
//            }
//
//        }
//
//
//    }
    
    
}





protocol UINoteViewDelegate: class {
    
    func touchHeard(onIndex index: Int)
    func doNothing()
    func refreshPulled()
    
}

extension UINoteViewDelegate{
    func refreshPulled(){}
}
