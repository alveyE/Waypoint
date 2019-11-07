//
//  SettingsViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 12/7/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var settingsStack: UIStackView! {
        didSet{
            let touch = UITapGestureRecognizer(target: self, action: #selector(settingsTouched))
            settingsStack.addGestureRecognizer(touch)
        }
    }
   
    @IBOutlet weak var securityStack: UIStackView!{
        didSet{
            let touch = UITapGestureRecognizer(target: self, action: #selector(securityTouched))
            securityStack.addGestureRecognizer(touch)
        }
    }
    
    
    @IBOutlet weak var aboutStack: UIStackView! {
        didSet{
             let touch = UITapGestureRecognizer(target: self, action: #selector(aboutTouched))
                       aboutStack.addGestureRecognizer(touch)
                   }
    }
    
    
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
    
    @objc private func settingsTouched(){
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController")
        self.show(settingsVC, sender: self)
    }

    @objc private func aboutTouched(){
        let aboutVC = self.storyboard!.instantiateViewController(withIdentifier: "AboutViewController")
        self.show(aboutVC, sender: self)
    }
    
    @objc private func securityTouched(){
        let securityVC = self.storyboard!.instantiateViewController(withIdentifier: "SecurityViewController")
        self.show(securityVC, sender: self)
    }
    
    private func determineShownElements(){
        displayNameLabel.adjustsFontSizeToFitWidth = true
        emailLabel.adjustsFontSizeToFitWidth = true
        if let user = Auth.auth().currentUser {
            displayNameLabel.text = user.displayName
            emailLabel.text = user.email
            signOutButton.isHidden = false
        }else{
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "signinNavigation")
        
    }
    

}
