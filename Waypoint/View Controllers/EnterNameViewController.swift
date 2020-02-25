//
//  EnterNameViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/24/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit

class EnterNameViewController: UIViewController {

    
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func nextPressed(_ sender: Any) {
        
        let firstName = firstNameLabel.text ?? ""
        let lastName = lastNameLabel.text ?? ""
        
        let enterEmail = self.storyboard!.instantiateViewController(withIdentifier: "enterEmail") as! EnterEmailViewController
        enterEmail.firstName = firstName
        enterEmail.lastName = lastName
                   enterEmail.modalPresentationStyle = .fullScreen
                   present(enterEmail, animated: true)
    }
    
}
