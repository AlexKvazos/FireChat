//
//  NewMessageController.swift
//  FireChat
//
//  Created by Alejandro Cavazos on 11/9/17.
//  Copyright © 2017 Alejandro Cavazos. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.title = "New Message"
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
        view.backgroundColor = UIColor(12,12,12)
        tableView.separatorColor = UIColor(30,30,30)
        
        fetchUser();
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
    
        let user = users[indexPath.row]
        cell?.textLabel?.text = user.name
        cell?.textLabel?.textColor = UIColor.white
        cell?.detailTextLabel?.text = user.email
        cell?.detailTextLabel?.textColor = UIColor.gray
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
}

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecorer: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




