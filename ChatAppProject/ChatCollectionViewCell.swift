//
//  ChatCollectionViewCell.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-22.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

class ChatCollectionViewCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tView = UITextView()
        tView.font = UIFont.systemFont(ofSize: 16)
        tView.translatesAutoresizingMaskIntoConstraints = false
        tView.backgroundColor = UIColor.clear
        tView.textColor = .white
        tView.isEditable = false
        return tView
    }()
    
    static let blueColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
    let bubblesView: UIView = {
       let view = UIView()
        view.backgroundColor = blueColor
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true
        return view;
    }()
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let locationImageView: UIImageView = {
        let locationView = UIImageView()
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.layer.cornerRadius = 10
        locationView.isUserInteractionEnabled = true
        locationView.image = UIImage(named: "map")
        locationView.layer.masksToBounds = true
        locationView.contentMode = .scaleAspectFill
        return locationView
    }()
    
    let locationMessage: UITextView = {
        let locationText = UITextView()
        locationText.font = UIFont.systemFont(ofSize: 16)
        locationText.isUserInteractionEnabled = true
        locationText.translatesAutoresizingMaskIntoConstraints = false
        locationText.backgroundColor = UIColor.clear
        locationText.textColor = .white
        locationText.isEditable = false
        return locationText
    }()
    
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleWidthConstraint : NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubblesView)
        addSubview(textView)
        bubblesView.addSubview(messageImageView)
        messageImageView.topAnchor.constraint(equalTo: bubblesView.topAnchor).isActive = true
        messageImageView.leftAnchor.constraint(equalTo: bubblesView.leftAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubblesView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubblesView.heightAnchor).isActive = true
        
        addSubview(locationImageView)
        locationImageView.topAnchor.constraint(equalTo: bubblesView.topAnchor,constant : 5).isActive = true
        locationImageView.leftAnchor.constraint(equalTo: bubblesView.leftAnchor,constant : 5).isActive = true
        locationImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        locationImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationImageView.isHidden = true;
        addSubview(locationMessage)
        locationMessage.leftAnchor.constraint(equalTo: locationImageView.rightAnchor, constant:  6).isActive = true
        locationMessage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        locationMessage.rightAnchor.constraint(equalTo: bubblesView.rightAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        locationMessage.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        locationImageView.isHidden = true;
        bubbleViewRightAnchor = bubblesView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubblesView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        bubblesView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthConstraint = bubblesView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthConstraint?.isActive = true
        
        bubblesView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubblesView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubblesView.rightAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
