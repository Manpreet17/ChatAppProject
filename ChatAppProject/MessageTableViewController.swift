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
    weak var activityIndicatorView: UIActivityIndicatorView!
    var messages = [Message]()
    var spinnerView = UIView.init()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        self.view.displayBlurEffect()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false);
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.view.hideBlurEffect()
        }
    }
    
    func lookUserMessages(){
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
                        message.latitude = dictionary["latitude"] as? Double
                        message.imageURL = dictionary["imageURL"] as? String
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.view.hideBlurEffect()
        }
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
        if(message.text != nil){
            cell.messageText.text=message.text
        }
        else if(message.latitude != nil){
            cell.messageText.text = "Attachment: Location"
        }
        else if(message.imageURL != nil){
            cell.messageText.text = "Attachment: Image"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        let message = self.messages[indexPath.row]
        if let partnerId = message.partnerId() {
            Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(uid).child(partnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                self.messagesDictionary.removeValue(forKey: partnerId)
                self.attemptReloadOfTable()
            })
        }
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
                    selfObj.lookUserMessages()
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
                let selectedUser =  user;
                chatLogViewController.user = selectedUser;
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
