//
//  MapSettingsViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/26/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit

class MapSettingsViewController: UIViewController {


    @IBOutlet weak var satalliteSwitch: UISwitch!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let satallite = defaults.bool(forKey: "satallite")
        print("Satallite is \(satallite)")
        satalliteSwitch.setOn(satallite, animated: false)
    }
    
 

    @IBAction func satalliteChanged(_ sender: Any) {
        let defaults = UserDefaults.standard

        if satalliteSwitch.isOn {
                defaults.set(true, forKey: "satallite")
        }else{
                defaults.set(false, forKey: "satallite")
        }
    }
    
    
   
    
    
}
