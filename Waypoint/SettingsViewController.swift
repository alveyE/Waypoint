//
//  SettingsViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var signedIn = false
    
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        determineShownElements()
        // Do any additional setup after loading the view.
    }
    
    
    
    private func determineShownElements(){
        
        
        
        if signedIn {
            
            signInButton.isHidden = true
            displayNameLabel.isHidden = false
            emailLabel.isHidden = false
            
        }else {
            
            signInButton.isHidden = false
            displayNameLabel.isHidden = true
            emailLabel.isHidden = true
            
            
        }
        
    }

   

}
