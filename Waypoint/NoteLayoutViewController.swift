//
//  NoteLayoutViewController.swift
//  Waypoint
//
//  Created by Bret Alvey on 12/19/18.
//  Copyright © 2018 Ethan Alvey. All rights reserved.
//

import UIKit

class NoteLayoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let note = UINoteView()
        note.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        note.addTitleWidget(title: "Test note", timeStamp: "20181219101034")
        note.addTextWidget(text: "Cookie monster is a unique character in todays world. I think it would be beneficial to let him eat all the cookies and watch the world in desperation for cookies! Cookie monster is a unique character in todays world. I think it would be beneficial to let him eat all the cookies and watch the world in desperation for cookies!")
        note.addImageWidget(image: UIImage(named: "mountain.jpg")!)
        view.addSubview(note)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
