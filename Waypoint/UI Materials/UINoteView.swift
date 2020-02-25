//
//  UINoteView.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/19/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseStorage


class UINoteView: UIView, ImageFrameViewDelegate, DrawingWidgetDelegate, TextWidgetDelegate, LinkWidgetDelegate, TitleViewDelegate {
    
    
    
    
    public var editable = false
    public var listStyle = false
    public var hasSaveButton = false
    public var hasCalanderIcon = true
    public var noteID = ""
    public var saved = false
    public var endYPositions = [CGFloat]()
    public var widgetAdderY: CGFloat = 0
    public var hasRefresh = false
    
    public lazy var scroll = createScrollView()
    
    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    private lazy var yPosition = height/15
    private lazy var padding = width/20
    private lazy var verticalPadding = height/50
    private var animationTime: TimeInterval = 0.3
    
    private var tapGestures: [UITapGestureRecognizer] = []
    private let noteTap = UITapGestureRecognizer(target: self, action: #selector(doNothing))
   
    weak var delegate: UINoteViewDelegate?
    weak var textReceiver: UITextViewDelegate?
    
    override func layoutSubviews() {
        if listStyle {
        padding = 0.0
        yPosition = 0.0
        }
        addSubview(scroll)
    }
    
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: self.bounds)
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
    
    func displayImage(image: UIImage) {
        delegate?.displayImage(image: image)
    }
    
    func menuAppear(withID id: String) {
        delegate?.menuAppear(withID: id)
    }
    
    @objc private func handleRefresh(_ control: UIRefreshControl){
        delegate?.refreshPulled()
        control.endRefreshing()
    }
    public func addTitleWidget(title: String, timeStamp: String, username: String, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0

        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
            let titleWidget = TitleView()
            titleWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width/4)
            titleWidget.hasShadow = !listStyle
            titleWidget.editable = editable
            titleWidget.delegate = self
            titleWidget.hasSaveButton = hasSaveButton
            titleWidget.hasCalendarIcon = hasCalanderIcon
            titleWidget.noteID = noteID
            titleWidget.saved = saved
            titleWidget.title = title
            titleWidget.noteTimeStamp = timeStamp
            titleWidget.username = username
            titleWidget.alpha = 0

            if listStyle {
                let seperatorLine = UIView(frame: CGRect(x: 0, y: titleWidget.frame.height, width: titleWidget.frame.width, height: 1))
                seperatorLine.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                titleWidget.addSubview(seperatorLine)
                
            }
        
        
            self.scroll.addSubview(titleWidget)
        
        UIView.animate(withDuration: animationTime) {
            titleWidget.alpha = 1

        }
        
        
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
            titleWidget.addGestureRecognizer(tap)
        
            tapGestures.append(tap)
            endYPositions.append(titleWidget.frame.maxY)
        
        if yPlacement == nil {
            if listStyle {
                yPosition += titleWidget.frame.height + 1
            }else {
                yPosition += titleWidget.frame.height + verticalPadding
            }
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
    
        
            let textWidget = TextWidget()
            textWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width * 17/48)
            textWidget.editable = editable
            textWidget.text = text
            textWidget.delegate = self
            textWidget.fitText()
            textWidget.alpha = 0
            scroll.addSubview(textWidget)
        UIView.animate(withDuration: animationTime) {
            textWidget.alpha = 1
            
        }
        
        if yPlacement == nil {
            yPosition += textWidget.frame.height + verticalPadding
        }
                textWidget.textContent.delegate = textReceiver
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
        imageWidget.delegate = self
        imageWidget.canDelete = editable
        var adjustedWidth = imageWidth
        var adjustedHeight = imageHeight
        
        
        let minimumPadding = (self.width - 2*self.padding) * 2/20
        
        let preAdj = adjustedWidth
        adjustedWidth = self.width - minimumPadding
        adjustedHeight *= (adjustedWidth/preAdj)
        adjustedHeight += minimumPadding/2
        
        imageWidget.frame = CGRect(x: self.padding, y: verticalPlacing, width: self.width - 2*self.padding, height: adjustedHeight)
        
        reference.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            let image = UIImage(data: data ?? Data()) ?? UIImage()
            
            
            imageWidget.image = image

           
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
        imageWidget.delegate = self
        imageWidget.canDelete = editable
        var adjustedWidth = imageWidth
        var adjustedHeight = imageHeight
        
        
        let minimumPadding = (self.width - 2*self.padding) * 2/20
        
        let preAdj = adjustedWidth
        adjustedWidth = self.width - minimumPadding
        adjustedHeight *= (adjustedWidth/preAdj)
        adjustedHeight += minimumPadding/2
        
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
        linkWidget.delegate = self
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
        
        let storage = Storage.storage()
        let imgadjurl = setImage + ".jpg"
        let reference = storage.reference(forURL: imgadjurl)
        
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        
        let drawingWidget = DrawingWidget()
        drawingWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width * 3/5)
        drawingWidget.delegate = self
        drawingWidget.canDelete = editable
        reference.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            let image = UIImage(data: data!) ?? UIImage()
            drawingWidget.drawingImage = image
        })
        
        scroll.addSubview(drawingWidget)
        if yPlacement == nil {
        yPosition += drawingWidget.frame.height + verticalPadding
        }
      //scroll.contentSize.height += drawingWidget.frame.height + verticalPadding
        adjustScroll()
        drawingWidget.addGestureRecognizer(noteTap)
    }
    
    
    public func addDrawingWidget(drawing: UIImage, yPlacement: CGFloat?){
        var verticalPlacing: CGFloat = 0
    
        if let yyy = yPlacement {
            verticalPlacing = yyy
        }else{
            verticalPlacing = yPosition
        }
        
        let drawingWidget = DrawingWidget()
        drawingWidget.frame = CGRect(x: padding, y: verticalPlacing, width: width - 2*padding, height: width * 3/5)
        drawingWidget.drawingImage = drawing
        drawingWidget.delegate = self
        drawingWidget.canDelete = editable
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
        if finished {
            finished = false
            
        if let titleTouched = sender as? UITapGestureRecognizer {
            if let index = tapGestures.firstIndex(of: titleTouched) {
            delegate?.touchHeard(onIndex: index)
                    
            }else{
                print("Error title tap not in taps array")
            }
        }
        }
    }
    
    public func popTitle(index: Int){
        (tapGestures[index].view as! TitleView).popAnimate()
    }
    
    func deleteWidget(_ widget : UIView) {
        
            if let imageWidget = widget as? ImageFrameView {
                delegate?.deletedImage(at: imageIndex(of: imageWidget))
            }
            if let drawingWidget = widget as? DrawingWidget {
            delegate?.deletedDrawing(at: drawingIndex(of: drawingWidget))
            }
            let totalAmnt = widget.frame.maxY - widget.frame.minY + getPadding()
            widget.removeFromSuperview()
            moveWidgets(overY: widget.frame.maxY, by: totalAmnt, down: false)
        
    }
    
    private func imageIndex(of imageWidget: ImageFrameView) -> Int{
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        var imagesFound = [ImageFrameView]()
        for sub in subCopy {
            if let ii = sub as? ImageFrameView {
                imagesFound.append(ii)
            }
        }
        return imagesFound.firstIndex(of: imageWidget) ?? -1
    }
    
    private func drawingIndex(of drawingWidget: DrawingWidget) -> Int{
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        var drawingsFound = [DrawingWidget]()
        for sub in subCopy {
            if let dd = sub as? DrawingWidget {
                drawingsFound.append(dd)
            }
        }
        return drawingsFound.firstIndex(of: drawingWidget) ?? -1
    }
    
    private var lastValue = CGFloat.greatestFiniteMagnitude
    public func checkExpansion(for text: UITextView, with value: CGFloat){
        var foundTextWidget = TextWidget()
        let shouldExpand = value > text.frame.height
        for sub in scroll.subviews {
            if let textWidget = sub as? TextWidget {
                if textWidget.textContent == text {
                    foundTextWidget = textWidget
                    break
                }
            }
        }
        if shouldExpand {
            
           let amountMoved = foundTextWidget.addLine(adding: true)
            moveWidgets(overY: foundTextWidget.frame.minY, by: amountMoved, down: true)
          
        }else if lastValue > value && foundTextWidget.frame.height > calculateHeight(of: "text", includePadding: false){
            let amountMoved = foundTextWidget.addLine(adding: false)
            moveWidgets(overY: foundTextWidget.frame.minY, by: amountMoved * -1, down: false)
        }
        lastValue = value
        
    }
    
        private func adjustScroll(){
        var contentRect = CGRect.zero
        let offset = scroll.contentOffset
        for view in scroll.subviews {
            if type(of: view) == TitleView.self || type(of: view) == TextWidget.self || type(of: view) == ImageFrameView.self || type(of: view) == DrawingWidget.self || type(of: view) == LinkWidget.self || type(of: view) == AddWidgetView.self {
                contentRect = contentRect.union(view.frame)
            }
        }
       
        scroll.contentSize.height = contentRect.size.height + leway()
        if scroll.contentSize.height < height {
            scroll.contentSize.height = height + 1
        }
        if editable {
        scroll.contentOffset = offset
        }
    }
    
    var finished = true
    
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
        finished = true
    }
    
    public func moveScroll(down: Bool, amount: CGFloat){
        var moveAmnt = amount
        if !down {
            moveAmnt *= -1
        }
        
        scroll.setContentOffset(CGPoint(x: 0, y: scroll.contentOffset.y + moveAmnt), animated: true)
    }
    
    public func moveToTop(index: Int){
        scroll.setContentOffset(CGPoint(x: 0, y: endYPositions[index] - (calculateHeight(of: "title", includePadding: true) + verticalPadding)), animated: true)
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
                            if let indexOfTap = tapGestures.firstIndex(of: tap) {
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
        UIView.animateKeyframes(withDuration: animationTime, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
            self.adjustScroll()
        }, completion: nil)
    }
    
    public func setTitle(to title: String){
        var subCopy = scroll.subviews
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        if let titleView = subCopy.first as? TitleView {
            titleView.title = title
        }
    }
    
    public func nextYmax(overY yVal: CGFloat) -> CGFloat {
        var subCopy = scroll.subviews
        var maxYValues = [CGFloat]()
        subCopy.sort(by: {$0.frame.minY < $1.frame.minY})
        
        for sub in subCopy {
            if sub.frame.minY > yVal {
            
            if let _ = sub as? TitleView {
                break
            }else {
                maxYValues.append(sub.frame.maxY)
            }
            }
        }
        return maxYValues.max() ?? 0
    }
    
    public func setStartY(to value: CGFloat){
        yPosition = value
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
                links.append(linkWidget.linkField.text ?? "")
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
            heightCalc =  width * 3/5
        }else if widgetType == "link" {
            heightCalc = width * 6/20
        }
        if includePadding {
            return heightCalc + verticalPadding
        }else{
            return heightCalc
        }
    }
    
    public func calculateTextHeight(of text: String, includePadding: Bool) -> CGFloat {
        
        let sampleWidget = TextWidget(frame: CGRect(x: 0, y: 0, width: width - 2*padding, height: width * 17/48))
        sampleWidget.textContent.text = text
        let newSize = sampleWidget.textContent.sizeThatFits(CGSize(width: sampleWidget.textContent.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let recommendedHeight = newSize.height
        while sampleWidget.textContent.frame.height < recommendedHeight {
            let _ = sampleWidget.addLine(adding: true)
        }
        if includePadding {
            return sampleWidget.frame.height + verticalPadding
        }else {
            return sampleWidget.frame.height
        }
    }
    
    public func calculateHeight(imageWidth: CGFloat, imageHeight: CGFloat, includePadding: Bool) -> CGFloat {
        var adjustedWidth = imageWidth
        var adjustedHeight = imageHeight
        
        
        let minimumPadding = (self.width - 2*self.padding) * 2/20
        
        let preAdj = adjustedWidth
        adjustedWidth = self.width - minimumPadding
        adjustedHeight *= adjustedWidth/preAdj
        adjustedHeight += minimumPadding/2

        
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
        removeWidgetsInRange(minY: -1, maxY: nil)
        yPosition = height/15
        if listStyle {
            yPosition = 0
        }
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
        return width/2
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
    }
    
    public func unHide(){
               self.alpha = 1
        
    }

    
}





protocol UINoteViewDelegate: class {
    func touchHeard(onIndex index: Int)
    func doNothing()
    func refreshPulled()
    func displayImage(image: UIImage)
    func menuAppear(withID id: String)
    func deletedImage(at index: Int)
    func deletedDrawing(at index: Int)
}

extension UINoteViewDelegate{
    func refreshPulled(){}
    func displayImage(image: UIImage){}
    func deletedImage(at index: Int){}
    func deletedDrawing(at index: Int){}
}
