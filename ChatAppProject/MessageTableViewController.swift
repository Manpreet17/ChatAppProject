//
//  MessageTableViewController.swift
//  ChatAppProject
//
//  Created by Mehak Luthra on 2018-11-18.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class MessageTableViewController: UITableViewController {
    
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    @IBOutlet weak var txtTitle: UINavigationItem!
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        observeMessage()
    }
    func observeMessage(){
        let messageRef = Database.database().reference().child("messages")
        messageRef.observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message()
                message.toId = dictionary["toId"] as? String
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? NSNumber
                self.messages.append(message)
                if let toId = message.toId{
                self.messagesDictionary[toId] = message
                self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: {(message1, message2)-> Bool in
                        return message1.timestamp!.intValue > message2.timestamp!.intValue
                    })
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }}, withCancel: nil)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MessageTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MessageTableViewCell.")
        }
        let message = messages[indexPath.row]
        if let toId = message.toId{
            let ref =  Database.database().reference().child("users").child(toId)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                 if let dictionary = snapshot.value as? [String: AnyObject]{
                    cell.toId.text = dictionary["name"] as? String
                }
            })
        }
        if let timeInSeconds = message.timestamp?.doubleValue{
            let timeStampDate = NSDate(timeIntervalSince1970: timeInSeconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            cell.timestamp.text=dateFormatter.string(from: timeStampDate as Date)
            
        }
        cell.messageText.text=message.text
        
        return cell
    }
    
    func checkIfUserLoggedIn(){
        let selfObj = self
        //check if user is not logged in
        if Auth.auth().currentUser?.uid == nil{
            logOutUser()
        }
        else{
            let user = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(user!).observeSingleEvent(of: .value, with:  {
                (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    selfObj.txtTitle.title = dictionary["name"] as? String
                }
            })
        }
    }
    
    func logOutUser(){
        do{
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
    }
    
    @IBAction func btnLogoutOnClick(_ sender: Any) {
        // logout user
        logOutUser()
        
        // Navigate to Login View Controller
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    
}
