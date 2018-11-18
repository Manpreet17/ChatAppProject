//
//  ChatLogViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-17.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController:UIViewController,UITextFieldDelegate {
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        messageText.delegate=self;
        navigationBar.title="Chat  Log"
    
}
    @IBAction func sendMessage(_ sender: Any) {
        let messageRef = Database.database().reference().child("messages")
        let childRef = messageRef.childByAutoId();
        let toId = "manpreet"//user.id!;
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970);
        
        let values = ["text":messageText.text!,"toId":toId,"fromId":fromId,"timestamp":timestamp] as [String : Any]
        childRef.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!)
                return
            }
            print("message saved into database")
        })
        messageText.text="";
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage(sendButton);
        return true;
    }
}
