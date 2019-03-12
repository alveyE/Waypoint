//
//  LinkWidget.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/19/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class LinkWidget: UIView {


    public var url = "https://fractyldev.com"
    
    private lazy var width = bounds.width
    private lazy var height = bounds.height
    
    private lazy var linkText = createLinkText()
    private lazy var shadow = createShadow()
    private var icon = UIImageView() {
        didSet{
            layoutSubviews()
        }
    }
    private var metaTitle = ""
    
    override func layoutSubviews() {
        layer.addSublayer(shadow)
        addSubview(linkText)
        addSubview(icon)
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
        setMetaImage()
        setTitleContent()
        return boxShadow
    }
    
    
    private func createLinkText() -> UITextView{
        let text = UITextView(frame: CGRect(x: width/4, y: height/3, width: width - width/4, height: height/3))
     //   text.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        tintColor = #colorLiteral(red: 0, green: 0, blue: 0.9803921569, alpha: 1)
        text.isEditable = false
        text.isScrollEnabled = false
        let textFont = UIFont(name: "Roboto-MediumItalic", size: 20)
        let centeredText = NSMutableParagraphStyle()
        centeredText.alignment = .center
        let attributes: [NSAttributedString.Key:Any] = [
            .font : textFont!,
            .paragraphStyle : centeredText,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
        ]
        let domainString: String = URL(string: url)?.host ?? url
        let linkedText = NSMutableAttributedString(string: domainString, attributes: attributes)
        let hyperlinked = linkedText.setAsLink(textToFind: domainString, linkURL: url)
        
        if hyperlinked {
            text.attributedText = NSAttributedString(attributedString: linkedText)
        }
        
        return text
    }
    
    
   
    
    func downloadImage(from imageURL: String) {
        var iconURL = imageURL
        if imageURL == "no image found" {
            iconURL = "https://image.flaticon.com/icons/png/512/93/93618.png"
        }
        while iconURL.first == " " {
            iconURL.remove(at: iconURL.startIndex)
        }
        while iconURL.last == " " {
            iconURL.removeLast()
        }
        print(iconURL)
        let url = URL(string: iconURL)
        print("Download Started")
        getData(from: url ?? URL(string: "https://image.flaticon.com/icons/png/512/93/93618.png")!) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url!.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                
                let icon = UIImage(data: data) ?? UIImage()
                //UI STUFF
                
                self.createImageIcon(with: icon)
                
            }
        }
    }
    
    private func createImageIcon(with icon: UIImage){
        
        //Scales keeping aspect ratio
        var originalHeight = icon.size.height
        let adjustedHeight = height * 2/3
        //Prevents dividing by 0 errors
        if originalHeight == 0 {
            originalHeight = 1
        }
        let scaledWidth = icon.size.width * (adjustedHeight/originalHeight)
        let imageView = UIImageView(image: icon)
        imageView.frame = CGRect(x: width - (width * 7/8), y: height/2 - height * 1/3, width: scaledWidth, height: adjustedHeight)
        if imageView.frame.width > height {
            let originalWidth = icon.size.width
            let adjustedWidth = height * 2/3
            let scaledHeight = icon.size.height * (adjustedWidth/originalWidth)
            imageView.frame = CGRect(x: width - (width * 7/8), y: height/2 - scaledHeight/2, width: adjustedWidth, height: scaledHeight)
            
        }
        
        
        self.icon = imageView
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func setTitleContent(){
        let url = URL(string: self.url)
        
        if url != nil {
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                //   print(data)
                
                if error == nil {
                    
                    let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as String? ?? ""
                    let title = urlContent.slice(from: "<title>", to: "</title>") ?? "no title found"
                    self.metaTitle = title
                }
            })
            task.resume()
        }
    }
    
    func setMetaImage(){
        let url = URL(string: self.url)
        
        if url != nil {
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                //   print(data)
                
                if error == nil {
                    
                    let urlContent = NSString(data: data!, encoding: String.Encoding.ascii.rawValue) as String? ?? ""

                    var imageUrl = urlContent.slice(from: "property=\"og:image\" content=\"", to: "\"") ?? "no image found"
                    
                    if imageUrl == "no image found" {
                        imageUrl = urlContent.slice(from: "<meta property=\"og:image\" itemprop=\"image primaryImageOfPage\" content=\"", to: "\"") ?? "no image found"
                    }
                    if imageUrl == "no image found" {
                        imageUrl = urlContent.slice(from: "icon\" href=\"", to: "\"") ?? "no image found"
                    }
                    if imageUrl == "no image found" {
                        imageUrl = urlContent.slice(from: "Logo\" src=\"", to: "\"") ?? "no image found"
                    }
                    if imageUrl == "no image found" {
                        imageUrl = urlContent.slice(from: "ICON\" href=\"", to: "\"") ?? "no image found"
                    }
                    if imageUrl == "no image found" {
                        
                        imageUrl = urlContent.slice(from: "img src = \"", to: "\"") ?? "no image found"
                        if imageUrl != "no image found" {
                            imageUrl = self.url + "/\(imageUrl)"
                        }
                    }
                    
                    

                    self.metaTitle = imageUrl
                    self.downloadImage(from: self.metaTitle)
                }
            })
            task.resume()
        }
    }
    

}


extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            
            self.addAttribute(.link, value: linkURL, range: foundRange)
            
            return true
        }
        return false
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
