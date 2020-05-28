//
//  AddGroupViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/27/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddGroupViewController: UIViewController, UISearchBarDelegate {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var rowButtons = [UIButton]()

    
    private var groupIDs = [String]()
    private var usersGroups = [String]()
    private var groups = [String]()
    private var groupNames = [String]()
    private var allIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchBar.delegate = self
        retrieveUserGroups()
        updateGroups()
    }
    

    @objc func plusTapped(_ sender: UIButton){
        let ref = Database.database().reference()

        var minusImage = UIImage()

        if #available(iOS 13.0, *) {
            minusImage = UIImage.remove
        } else {
            // Fallback on earlier versions
        }
        
        var plusImage = UIImage()

        if #available(iOS 13.0, *) {
            plusImage = UIImage.add
        } else {
            // Fallback on earlier versions
        }
        if let index = rowButtons.lastIndex(of: sender) {
        let groupID = groupIDs[index]
        if let user = Auth.auth().currentUser {
            
            if groupID.first ?? " " == "F" {
                
                //Remove Group
//ref.child("users").child(user.uid).child("groups").childByAutoId().setValue(["groupID" : groupID])
//                ref.child("groups").child(groupID).child("members").childByAutoId().setValue(user.uid)
                
                    sender.setImage(plusImage, for: .normal)
                    groupIDs[index].removeFirst()
            }else{
            ref.child("users").child(user.uid).child("groups").childByAutoId().setValue(["groupID" : groupID])
            ref.child("groups").child(groupID).child("members").childByAutoId().setValue(user.uid)
            
            sender.setImage(minusImage, for: .normal)
                groupIDs[index].insert("F", at: groupIDs[index].startIndex)
            }
            
        }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        groups = [String]()
        groupIDs = [String]()
        tableView.reloadData()
        for i in groupNames.indices {
            if groupNames[i].lowercased().contains(searchText.lowercased()){
                groups.append(groupNames[i])
                if usersGroups.contains(allIDs[i]){
                    groupIDs.append("F"+allIDs[i])

                }else{
                    groupIDs.append(allIDs[i])
                }
                
                let indexPath = IndexPath(row: self.groups.count-1, section: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                
                
            }
        }
    }
    
    
    func retrieveUserGroups(){
        if let user = Auth.auth().currentUser {
                   ref = Database.database().reference()
                    
            
            ref.child("users").child(user.uid).child("groups").observe(DataEventType.value) { (snapshot) in
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    if let childData = childSnapshot.value as? [String : Any] {
                                              
                        if let idToAdd = childData["groupID"] as? String {
                            if !self.usersGroups.contains(idToAdd){
                                self.usersGroups.append(idToAdd)

                            }
                                    }
                                              
                                              
                            }
                    }
            }
                
        }
    }
    
    private func updateGroups(){
        ref = Database.database().reference()
        ref.child("groups").observe(DataEventType.value, with: { (snapshot) in
           
            for case let childSnapshot as DataSnapshot in snapshot.children {
                //                let key = childSnapshot.key
                if let childData = childSnapshot.value as? [String : Any] {
                    
                    if let name = childData["name"] as? String {
                    let idRetrieved = childSnapshot.key
                    self.groupNames.append(name)
                    self.allIDs.append(idRetrieved)
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

}

extension AddGroupViewController: UITableViewDataSource, UITableViewDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection    section: Int) -> Int {
        return groups.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = groups[indexPath.row]
        let plusButton = UIButton()
        var plusImage = UIImage()

        if #available(iOS 13.0, *) {
            plusImage = UIImage.add
        } else {
            // Fallback on earlier versions
        }
        if usersGroups.contains(allIDs[indexPath.row]){
            if #available(iOS 13.0, *) {
                plusImage = UIImage.remove
            } else {
                // Fallback on earlier versions
            }
        }

        plusButton.sizeToFit()
        plusButton.setImage(plusImage, for: .normal)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        rowButtons.append(plusButton)
        cell.accessoryView = plusButton
           return cell

   }
    func tableView(_ tableView: UITableView,
               heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark

    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
  //      tableView.cellForRow(at: indexPath)!.accessoryType = .none

    }
 
}
