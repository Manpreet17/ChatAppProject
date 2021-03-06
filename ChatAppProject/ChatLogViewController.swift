//
//  ChatLogViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-17.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import os.log
class ChatLogViewController:UICollectionViewController, UITextFieldDelegate,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [Message]()
    var flag = 0;
    var containerBottomAnchor: NSLayoutConstraint?
    var spinnerView = UIView.init()
    var latitude = 0.0;
    var longitude = 0.0
    let cellId = "cellId";
    var city = ""
    
    var user : Users?{
        didSet{
            print(user?.name as Any)
            self.navItem.title  = user?.name
            self.flag = 0
            lookForMessages();
        }}
    
    lazy var messageText: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var navItem: UINavigationItem = {
        let navItem = UINavigationItem(title: "Title");
        return navItem
    }()
    
    lazy var navBar: UINavigationBar = {
        let navItem = self.navItem
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: #selector(launchMessageTableViewController))
        navBar.setItems([navItem], animated: false);
        return navBar
    }()
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return sendButton
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(navBar);
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive =  true
        navBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive =  true
        navBar.topAnchor.constraint(equalTo: view.topAnchor, constant:15).isActive = true
        navBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        navBar.barTintColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        navBar.isTranslucent = false
        //view.addSubview(containerView)
        
        let sendLocationView = UIImageView()
        sendLocationView.image = UIImage(named: "location")
        sendLocationView.translatesAutoresizingMaskIntoConstraints = false
        sendLocationView.isUserInteractionEnabled = true
        sendLocationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendLocation)))
        containerView.addSubview(sendLocationView)
        sendLocationView.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant: 3).isActive = true
        sendLocationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendLocationView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        sendLocationView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "photoLibrary")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImage)))
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: sendLocationView.rightAnchor,constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(messageText)
        messageText.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        messageText.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageText.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        messageText.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0);
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        messageText.delegate=self;
        collectionView?.contentInset = UIEdgeInsets(top: 48, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true;
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        statusBar?.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        self.spinnerView = startSpin(onView: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false);
        if(self.flag==0){
            self.stopSpin(spinner: self.spinnerView)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardShow(notificationObject : NSNotification){
        let frame = (notificationObject.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let duration = (notificationObject.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerBottomAnchor?.constant = -frame!.height
        UIView.animate(withDuration: duration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardHide(notificationObject : NSNotification){
        let duration = (notificationObject.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerBottomAnchor?.constant = 0
        UIView.animate(withDuration: duration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func launchMessageTableViewController(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MessageTableViewController") as! MessageTableViewController
        self.present(nextViewController, animated:true, completion:{self.containerView.isHidden = true;})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.containerView.isHidden = false;
        self.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage?{
            selectedImage = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage?{
            selectedImage = originalImage
        }
        if let selectedImg = selectedImage{
            uploadImageToFirebase(image: selectedImg)
        }
        self.dismiss(animated: true, completion: { self.containerView.isHidden = false;})
        self.spinnerView = startSpin(onView: self.view)
    }

    func uploadImageToFirebase(image: UIImage){
        let selfObj = self
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messageImages").child(imageName)
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            ref.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                if error != nil{
                    print("failed to upload image! ", error as Any)
                    return
                }
                ref.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    selfObj.sendMessageWithImageURL(imageURL: (url?.absoluteString)!, image: image)
                })
            })
        }
    }
    
    fileprivate func sendMessageWithImageURL(imageURL: String, image: UIImage){
        let messageRef = Database.database().reference().child("messages")
        let childRef = messageRef.childByAutoId();
        let toId = user!.id!;
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970);
        
        let values = ["imageURL":imageURL, "imageWidth":image.size.width, "imageHeight":image.size.height,"toId":toId,"fromId":fromId,"timestamp":timestamp] as [String : Any]
        childRef.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: {(err, messageRef) in
            if err != nil{
                print(err!)
                return
            }
            self.messageText.text = nil;
            let ref = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key;
            let values = [messageId:1]
            ref.updateChildValues(values)
            let reciepentRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(toId).child(fromId)
            reciepentRef.updateChildValues(values)
            
            print("message saved")
        })
        stopSpin(spinner: self.spinnerView)
    }
    
    @objc func handleUploadImage(){
        //incomplete
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true;
        self.containerView.isHidden = true;
        imagePickerController.delegate = self;
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleSendLocation(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        nextViewController.user = user
        self.present(nextViewController, animated:true, completion:{self.containerView.isHidden = true;})
    }
    
    func lookForMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let userMessagesRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            self.flag = 1;
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
                if(dictionary["text"] != nil){
                    message.text = dictionary["text"] as? String
                }
                else if (dictionary["latitude"] != nil && dictionary["longitude"] != nil){
                    message.latitude = dictionary["latitude"] as? Double
                    message.longitude = dictionary["longitude"] as? Double
                }
                else if (dictionary["imageURL"] != nil){
                    message.imageURL = dictionary["imageURL"] as? String
                    message.imageHeight = dictionary["imageHeight"] as? NSNumber
                    message.imageWidth = dictionary["imageWidth"] as? NSNumber
                    //self.containerView.isHidden = false;
                }
                message.timestamp = dictionary["timestamp"] as? NSNumber
                //if message.partnerId() == self.user?.id{
                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.stopSpin(spinner: self.spinnerView)
                }
            }, withCancel: nil)
        }, withCancel: nil )
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatCollectionViewCell
        let message = messages[indexPath.item]
        setUpCellUI(cell: cell, message: message)
        
        if message.imageURL != nil{
            cell.bubbleWidthConstraint?.constant = 200
            return cell
        }
        if(message.text != nil) && (message.text != ""){
            cell.textView.text = message.text
            cell.bubbleWidthConstraint?.constant = estimateHeightOfMessage(text: message.text!).width + 32
            return cell
        }
        if (message.longitude != nil){
            fetchCityAndCountry(currentLocation: CLLocation(latitude: message.latitude!, longitude: message.longitude!), completion: { city,country in
                DispatchQueue.main.async(execute: {
                    cell.locationMessage.text = "\(city), \(country)"
                })
            })
            self.latitude = message.latitude!
            self.longitude = message.longitude!
            setUpCellUI(cell: cell, message: message)
            cell.bubbleWidthConstraint?.constant = estimateHeightOfMessage(text: "latitude: \(String(describing: message.latitude!)) longitude: \(String(describing: message.longitude!))").width+32
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapClicked))
            cell.locationImageView.addGestureRecognizer(tapGesture)
            cell.locationMessage.addGestureRecognizer(tapGesture)
            cell.addGestureRecognizer(tapGesture)
            return cell
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let textMessage = messages[indexPath.item].text{
            height = estimateHeightOfMessage(text: textMessage).height + 20
        }
        else if let locationMessage = messages[indexPath.item].latitude{
            height = estimateHeightOfMessage(text: "\(locationMessage)").height + 40
        }
        else if let imgwidth = message.imageWidth?.floatValue, let imgheight = message.imageHeight?.floatValue{
            height = CGFloat( imgheight / imgwidth * 200)
        }
        return CGSize(width: view.frame.width, height: height);
    }
    
    func fetchCityAndCountry(currentLocation: CLLocation,completion:@escaping (String,String)->()){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
            
            if (error != nil) {
                
                os_log("Reverse geocoder failed with error %s", type: OSLogType.error, error!.localizedDescription)
            } else {
                
                let place = placemarks![0]
                completion(place.locality!,place.country!)
            }
        })
    }
    
    private func setUpCellUI(cell : ChatCollectionViewCell, message: Message){
        
        if message.fromId == Auth.auth().currentUser!.uid{
            //sent message bubble
            cell.bubblesView.backgroundColor = ChatCollectionViewCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.locationMessage.textColor = UIColor.white
            
        }
        else{
            //received message bubble
            cell.bubblesView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.locationMessage.textColor = UIColor.black
            
        }
        if  message.text != nil {
            cell.textView.isHidden = false;
            cell.locationImageView.isHidden = true
            cell.locationMessage.isHidden = true
            cell.messageImageView.isHidden = true
            
        }
        else if let messageImageUrl = message.imageURL {
            cell.messageImageView.imgLoadCacheOrUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubblesView.backgroundColor = UIColor.clear
            cell.textView.isHidden = true
            cell.locationImageView.isHidden = true
            cell.locationMessage.isHidden = true
        }
        else if message.latitude != nil {
            cell.locationImageView.isHidden = false;
            cell.locationMessage.isHidden = false;
            cell.textView.isHidden = true
            cell.messageImageView.isHidden = true
        }
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
        if(self.messageText.text == ""){
        }
        else{
            //observed error here to be discussed
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
                let ref = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key;
                let values = [messageId:1]
                ref.updateChildValues(values)
                let reciepentRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(toId).child(fromId)
                reciepentRef.updateChildValues(values)
                print("message saved")
            })
        }
    }
    
    @objc func mapClicked(){
        let latitude: CLLocationDegrees = self.latitude
        let longitude: CLLocationDegrees = self.longitude
        
        let regionDistance:CLLocationDistance = 200
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Location"
        mapItem.openInMaps(launchOptions: options)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.text != ""){
            sendMessage();
        }
        return true;
    }
  
}
