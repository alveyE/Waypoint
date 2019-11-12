//
//  SettingsViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 10/24/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUserInfo()
    }
    
    @IBAction func cellularDataTouched(_ sender: Any) {
        
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    
    private func displayUserInfo(){
       
        displayNameLabel.adjustsFontSizeToFitWidth = true
        emailLabel.adjustsFontSizeToFitWidth = true
      
        if let user = Auth.auth().currentUser {
            displayNameLabel.text = user.displayName
            emailLabel.text = user.email
        }else{
            displayNameLabel.text = ""
            emailLabel.text = ""
        }
  

}
    
}
