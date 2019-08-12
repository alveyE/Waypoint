//
//  GroupManagerViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 5/11/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import UIKit

class GroupManagerViewController: UIViewController {

    var groupNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        createElements()
    }
    
    
    private func createElements(){
        
        
        let createButtonWidth = view.frame.width * 19/20
        groupNameField = UITextField(frame: CGRect(x: view.frame.width / 2 - (createButtonWidth/2), y: view.frame.height/4, width: createButtonWidth, height: createButtonWidth/8));
        groupNameField.placeholder = "Enter group name"
        let createButton = UIButton(frame: CGRect(x: view.frame.width / 2 - (createButtonWidth/2), y: view.frame.height/3, width: createButtonWidth, height: createButtonWidth/8))
        createButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        createButton.setTitle("Create", for: .normal)
        
        view.addSubview(groupNameField)
        view.addSubview(createButton)
    }

    
    @objc private func createGroup(){
        print(groupNameField.text)
    }
    

}
