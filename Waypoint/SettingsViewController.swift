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
    
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var signOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        determineShownElements()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        determineShownElements()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.view = nil
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
            signInButton.isHidden = true
            displayNameLabel.text = user.displayName
            emailLabel.text = user.email
            signOutButton.isHidden = false
        }else{
            signInButton.isHidden = false
            displayNameLabel.text = ""
            emailLabel.text = ""
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
