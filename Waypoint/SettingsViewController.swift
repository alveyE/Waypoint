//
//  SettingsViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    var signedIn = false
    
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var signOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        determineShownElements()
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet var mainView: UIView! {
        didSet{
            let tap = UITapGestureRecognizer(target: self, action: #selector(disableKeyboard))
            mainView.addGestureRecognizer(tap)
        }
    }
    
    
    @objc private func disableKeyboard(){
        mainView.endEditing(true)
    }
    
    
    private func determineShownElements(){
        
        if let user = Auth.auth().currentUser {
            signedIn = true
        }else{
            signedIn = false
        }

        if signedIn {

            signInButton.isHidden = true
            displayNameLabel.isHidden = false
            emailLabel.isHidden = false
            signOutButton.isHidden = false
        }else {

            signInButton.isHidden = false
            displayNameLabel.isHidden = true
            emailLabel.isHidden = true
            signOutButton.isHidden = true

        }

    }

    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        Auth.auth()
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        determineShownElements()
        
    }
    

}
