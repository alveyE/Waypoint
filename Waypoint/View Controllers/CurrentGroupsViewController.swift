//
//  CurrentGroupsViewController.swift
//  Waypoint
//
//  Created by Ethan Alvey on 2/27/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class CurrentGroupsViewController: UIViewController {

    var ref: DatabaseReference!

    
    private var groupIDs: [String] = [
        "Public"
    ]
    private var groups: [String] = [
        "Public"
    ]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

       showGroups()
        
        let back = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(addTapped))
        
        navigationItem.leftBarButtonItem = back

        
        
    }
   
    
    @objc func addTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    private func showGroups(){
        tableView.register(GroupTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        retrieveGroupNames()
    }
let cellReuseIdentifier = "cell"
    
    
    func retrieveGroupNames(){
        if let user = Auth.auth().currentUser {
                   ref = Database.database().reference()
                    
            
            ref.child("users").child(user.uid).child("groups").observe(DataEventType.value) { (snapshot) in
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    if let childData = childSnapshot.value as? [String : Any] {
                                              
                        if let idToAdd = childData["groupID"] as? String {
                            if !self.groupIDs.contains(idToAdd){
                                self.groupIDs.append(idToAdd)
                                self.getGroupName(withID: idToAdd)
                            }
                                    }
                                              
                                              
                            }
                    }
            }
                
        }
    }
    
    func getGroupName(withID groupID: String){
        ref = Database.database().reference()
               
               ref.child("groups").child(groupID).observeSingleEvent(of: .value, with: { (snapshot) in
                  if let value = snapshot.value as? [String : Any] {
                    let name = value["name"] as? String ?? ""
                    self.groups.append(name)
                    let indexPath = IndexPath(row: self.groups.count-1, section: 0)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                    
                
                }
        })
    }
    
    
    
    
}

extension CurrentGroupsViewController: UITableViewDataSource, UITableViewDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection    section: Int) -> Int {
        return groups.count
    }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
        let cell:GroupTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! GroupTableViewCell
    let groupName = groups[indexPath.row]
    cell.groupTitle.text = groupName
    let idForCell = groupIDs[indexPath.row]
    cell.groupID = idForCell
    let defaults = UserDefaults.standard
    let shouldBeOn = defaults.bool(forKey: idForCell)
    cell.selectSwitch.setOn(shouldBeOn, animated: false)
           return cell

   }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
        // TODO: DELETE GROUP FROM USER
        
        groups.remove(at: indexPath.row)
        groupIDs.remove(at: indexPath.row)

        tableView.deleteRows(at: [indexPath], with: .fade)
     }
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


