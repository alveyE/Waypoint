//
//  GroupTableViewCell.swift
//  Waypoint
//
//  Created by Ethan Alvey on 3/10/20.
//  Copyright © 2020 Ethan Alvey. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    
    var selectSwitch = UISwitch()
    var groupTitle = UILabel()
    public var groupID = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(selectSwitch)
        addSubview(groupTitle)
        
        configureTitle()
        configureSelectSwitch()
        
        setSwitchConstraints()
        setTitleConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
  //      super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configureSelectSwitch(){
        selectSwitch.onTintColor = UIColor.blue
        selectSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    
    func configureTitle(){
      
        
        
    }
    
    @objc private func switchChanged(){
        let defaults = UserDefaults.standard
        defaults.set(selectSwitch.isOn, forKey: groupID)
    }
    
    
    func setSwitchConstraints(){
        selectSwitch.translatesAutoresizingMaskIntoConstraints = false
        selectSwitch.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        selectSwitch.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        
        
    }
    
    func setTitleConstraints(){
        groupTitle.translatesAutoresizingMaskIntoConstraints = false
              groupTitle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
              groupTitle.leadingAnchor.constraint(equalTo: selectSwitch.leadingAnchor, constant: 100).isActive = true
              groupTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
              groupTitle.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
}
