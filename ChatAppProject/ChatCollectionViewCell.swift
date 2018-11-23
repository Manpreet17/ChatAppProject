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
        tView.text = "SAMPLE TEXT FOR NOW"
        tView.font = UIFont.systemFont(ofSize: 16)
        tView.translatesAutoresizingMaskIntoConstraints = false
        tView.backgroundColor = UIColor.clear
        tView.textColor = .white
        tView.isEditable = false
        return tView
    }()
    let bubblesView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true
        return view;
    }()
    var bubbleWidthConstraint : NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubblesView)
        addSubview(textView)
        
        bubblesView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
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
