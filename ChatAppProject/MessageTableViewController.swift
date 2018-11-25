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
    }
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let usermessageRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(uid)
        usermessageRef.observe(.childAdded, with: {(snapshot) in
            let userId = snapshot.key;
            
            Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                let messageRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("messages").child(messageId)
                messageRef.observe(.value, with: {(snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        let message = Message()
                        message.toId = dictionary["toId"] as? String
                        message.fromId = dictionary["fromId"] as? String
                        message.text = dictionary["text"] as? String
                        message.timestamp = dictionary["timestamp"] as? NSNumber
                        self.messages.append(message)
                        if let partnerId = message.partnerId(){
                            self.messagesDictionary[partnerId] = message
                            self.messages = Array(self.messagesDictionary.values)
                            self.messages.sort(by: {(message1, message2)-> Bool in
                                return message1.timestamp!.intValue > message2.timestamp!.intValue
                            })
                        }
                        self.attemptReloadOfTable()
                    }
                },withCancel: nil)
            },withCancel: nil)
                
            },withCancel: nil)
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
                        
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                    //                self.timer?.invalidate()
                    //                print("canceled our timer")
                    //
                    //                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    //                print("schedule table reload in 0.1 sec")
                    
                }}, withCancel: nil)
        }
        var timer: Timer?
    
    func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
        @objc func handleReloadTable() {
            self.messages = Array(self.messagesDictionary.values)
            self.messages.sort(by: {(message1, message2)-> Bool in
                return message1.timestamp!.intValue > message2.timestamp!.intValue
            })
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
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
            
            if let id = message.partnerId(){
                let ref =  Database.database().reference().child("users").child(id)
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
                        selfObj.messages.removeAll();
                        selfObj.messagesDictionary.removeAll();
                        selfObj.tableView.reloadData();
                        selfObj.observeUserMessages()
                    }
                })
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.destination is ChatLogViewController{
                guard let chatLogViewController = segue.destination as? ChatLogViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                guard let selectedUserCell = sender as? MessageTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                let message = messages[indexPath.row]
                guard let partnerId = message.partnerId() else{
                    return
                }
                let userRef = Database.database().reference().child("users").child(partnerId)
                
                userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                    guard let dictionary = snapshot.value as? [String: AnyObject] else{
                        return
                    }
                    let user = Users()
                    user.id = partnerId
                    // user.id = dictionary["id"] as? String
                    user.name = dictionary["name"] as? String
                    user.email = dictionary["email"] as? String
                    
                    //let chatLogController = ChatLogViewController(collectionViewLayout: UICollectionViewFlowLayout())
                    let selectedUser =  user;
                    chatLogViewController.user = selectedUser;
                    //chatLogController.user =  users[indexPath.row]
                    //self.navigationController?.pushViewController(chatLogController, animated: true)
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
