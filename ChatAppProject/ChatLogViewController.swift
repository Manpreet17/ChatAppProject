//
//  ChatLogViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-17.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController:UICollectionViewController, UITextFieldDelegate,UICollectionViewDelegateFlowLayout {
    var user : Users?{
    didSet{
        print(user?.name as Any)
         //navigationBar?.title = user?.name
        observeMessages();
        }}
    var messages = [Message]()
    
    lazy var messageText: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    override func viewDidLoad() {
        
        super.viewDidLoad();
        messageText.delegate=self;
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true;
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        setupInputComponents()
      //  observeMessages()
        //self.navigationItem.title = user?.name
}
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
//        let navItem = UINavigationItem(title: "SomeTitle");
//        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
//        containerView.addSubview(navBar);
//        navItem.rightBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: #selector(launchMessageTableViewController))
//        navBar.setItems([navItem], animated: false);
        //ios9 constraint anchors
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(messageText)
        //x,y,w,h
        messageText.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        messageText.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageText.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageText.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0);
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    @objc func launchMessageTableViewController(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MessageTableViewController") as! MessageTableViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot);
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message()
                message.toId = dictionary["toId"] as? String
                message.fromId = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? NSNumber
                if message.partnerId() == self.user?.id{
                    self.messages.append(message)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                        //scroll to the last index
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    })
                }
            
        }, withCancel: nil)
    }, withCancel: nil)
    }
    let cellId = "cellId";
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatCollectionViewCell
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        //set bubble width according to message
        cell.bubbleWidthConstraint?.constant = estimateHeightOfMessage(text: message.text!).width + 32
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let textMessage = messages[indexPath.item].text{
            height = estimateHeightOfMessage(text: textMessage).height + 20
        }
        return CGSize(width: view.frame.width, height: height);
    }
    private func estimateHeightOfMessage(text: String) -> CGRect{
        let size = CGSize(width: 200, height:1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func sendMessage() {
        let messageRef = Database.database().reference().child("messages")
        let childRef = messageRef.childByAutoId();
        let toId = user!.id!;
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970);
        
        let values = ["text":messageText.text!,"toId":toId,"fromId":fromId,"timestamp":timestamp] as [String : Any]
        childRef.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: {(err, messageRef) in
            if err != nil{
                print(err!)
                return
            }
            self.messageText.text = nil;
            let ref = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(fromId)
            let messageId = childRef.key;
            let values = [messageId:1]
            ref.updateChildValues(values)
            let reciepentRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(toId)
            reciepentRef.updateChildValues(values)
            print("message saved")
            })
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage();
        return true;
    }
}
