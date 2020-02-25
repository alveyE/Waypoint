//
//  BirthdaySelectorViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/23/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit

class BirthdaySelectorViewController: UIViewController {


    public var firstName = ""
    public var lastName = ""
    public var emailCreated = ""
    public var usernameCreated = ""
    public var passwordCreated = ""
    
    private var birthdayEntered = ""
    
    @IBOutlet weak var birthdayTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        birthdayTextField.inputView = datePicker
    let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)
    }
    
    @objc func viewTapped(){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
     
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        birthdayTextField.text = dateFormatter.string(from: datePicker.date)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthdayEntered = dateFormatter.string(from: datePicker.date)
        errorLabel.isHidden = true
    }

    @IBAction func nextPressed(_ sender: Any) {
        if ageVerifier() {
            let termsPrivacyAgree = self.storyboard!.instantiateViewController(withIdentifier: "termsPrivacyAgree") as! TermsPrivacyAgreeViewController
                        termsPrivacyAgree.emailCreated = emailCreated
                        termsPrivacyAgree.usernameCreated = usernameCreated
                        termsPrivacyAgree.firstName = firstName
                        termsPrivacyAgree.lastName = lastName
                        termsPrivacyAgree.passwordCreated = passwordCreated
                        termsPrivacyAgree.birthday = birthdayEntered
                                
                              termsPrivacyAgree.modalPresentationStyle = .fullScreen
                              present(termsPrivacyAgree, animated: true)
        }
        else{
            errorLabel.isHidden = false
        }
    }
    private func ageVerifier() -> Bool{
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year], from: Date(), to: datePicker!.date)
        let years = -(dateComponents.year ?? 0)
        return years >= 13
        
    }
    
}
