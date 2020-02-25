//
//  TermsPrivacyAgreeViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/24/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class TermsPrivacyAgreeViewController: UIViewController {

    public var firstName = ""
    public var lastName = ""
    public var emailCreated = ""
    public var usernameCreated = ""
    public var passwordCreated = ""
    public var birthday = ""
    
    var ref: DatabaseReference!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var termsLink: UITextView!
    
    @IBOutlet weak var privacyLink: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setLinks()
        // Do any additional setup after loading the view.
    }
    private func setLinks(){
           let termsAttributedText = NSMutableAttributedString(string: termsLink.text)
           let privacyAttributedText = NSMutableAttributedString(string: privacyLink.text)
        let termsRange = (termsAttributedText.string as NSString).range(of: "Terms of Service")
         let privacyRange = (privacyAttributedText.string as NSString).range(of: "Privacy Policy")
        termsAttributedText.addAttributes([NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 28)!], range: termsRange)
        privacyAttributedText.addAttributes([NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 28)!], range: privacyRange)
           let _ = termsAttributedText.setAsLink(textToFind: "Terms of Service", linkURL: "https://waypoint.fractyldev.com/terms.html")
           let _ = privacyAttributedText.setAsLink(textToFind: "Privacy Policy", linkURL: "https://waypoint.fractyldev.com/privacy.html")
           termsLink.attributedText = NSAttributedString(attributedString: termsAttributedText)
            
            privacyLink.attributedText = NSAttributedString(attributedString: privacyAttributedText)
       }
    

    @IBAction func nextPressed(_ sender: Any) {
        
        Auth.auth().createUser(withEmail: emailCreated, password: passwordCreated, completion: { (authresult, error) in
        if error != nil {
            self.errorLabel.text = "Error creating account"
            self.errorLabel.isHidden = false
            print("error \(String(describing: error))")
            return
        }
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = self.usernameCreated
        changeRequest?.commitChanges(completion: { (error) in
            if error != nil {
                print("error \(String(describing: error))")
                return
            }
        })
        })
        
        
        //Upload user to database as well
        if let user = Auth.auth().currentUser {
            
           
            self.ref = Database.database().reference()
            self.ref.child("users").child(user.uid).setValue(["username": usernameCreated, "email" : emailCreated, "first name" : firstName, "last name" : lastName, "birthday" : birthday])
            self.ref.child("users").child("usernames").child(user.uid).setValue(["username" : usernameCreated])
        
        
        }
                //Start at map
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
        
        
    }
    
}
