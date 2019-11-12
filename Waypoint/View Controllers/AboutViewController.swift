//
//  AboutViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 11/7/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    
    
    @IBOutlet weak var privacyText: UITextView! {
        didSet{
            let privacyAttributedText = NSMutableAttributedString(string: privacyText.text, attributes: [.font: UIFont.systemFont(ofSize: 32)])
                  let _ = privacyAttributedText.setAsLink(textToFind: "Privacy Policy", linkURL: "https://fractyldev.com/waypoint/privacy")
                  privacyText.attributedText = NSAttributedString(attributedString: privacyAttributedText)
        }
    }
    
    
    @IBOutlet weak var termsText: UITextView! {
        didSet{
            let termsAttributedText = NSMutableAttributedString(string: termsText.text, attributes: [.font: UIFont.systemFont(ofSize: 32)])
                let _ = termsAttributedText.setAsLink(textToFind: "Terms of Use", linkURL: "https://fractyldev.com/waypoint/terms")
                    
                  termsText.attributedText = NSAttributedString(attributedString: termsAttributedText)
            
        }
    }
    
    @IBOutlet weak var descriptionText: UITextView!
    {
        didSet{
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
}
