//
//  ChatTableViewController.swift
//  ChatAppProject
//
//  Created by Mehak Luthra on 2018-11-11.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UITableViewController {

    var users = [Users]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "UserTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell.")
        }
        let user = users[indexPath.row]
        cell.userName.text = user.name
        cell.userEmail.text = user.email
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    func fetchUsers(){
        Database.database().reference().child("users").observe(.childAdded, with: {
            (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = Users()
                user.id = snapshot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                if(user.id != Auth.auth().currentUser?.uid){
                    self.users.append(user)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChatLogViewController{
            guard let chatLogViewController = segue.destination as? ChatLogViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedUserCell = sender as? UserTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedUser = users[indexPath.row];
            chatLogViewController.user = selectedUser;
        }
    }
    
}
