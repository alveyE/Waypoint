//
//  FullScreenImageViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 4/12/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController, UIScrollViewDelegate {

    
    private lazy var width = view.frame.width
    private lazy var height = view.frame.height
    
    
    private lazy var imageView = createImageView()
    
    public var image = UIImage(){
        didSet{
            createScroll()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        createScroll()
        // Do any additional setup after loading the view.
    }
    
     func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    private func createScroll(){
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        scrollView.delegate = self
        scrollView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        scrollView.maximumZoomScale = 15
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(scrollTapped))
        swipe.direction = .down
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollTapped))
        scrollView.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(swipe)
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
    }
    
    @objc func scrollTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createImageView() -> UIImageView{
        var preWidth = image.size.width
        if preWidth == 0 {
            preWidth = 1
        }
        let scaleFactor = view.frame.width / preWidth
        let imageView = UIImageView(frame: CGRect(x: 0, y: view.frame.height/2 - (image.size.height * scaleFactor)/2, width: view.frame.width, height: image.size.height * scaleFactor))
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(imageHeld))
        imageView.addGestureRecognizer(longPress)
        return imageView
    }
    
    @objc func imageHeld(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let save = UIAlertAction(title: "Save Photo", style: .default, handler: { action in
            self.saveImage(self.imageView.image!)
        })
        alert.addAction(cancel)
        alert.addAction(save)
        self.present(alert, animated: true, completion: nil)
    }
    

    private func saveImage(_ image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}
