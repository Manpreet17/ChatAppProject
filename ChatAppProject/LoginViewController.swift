//
//  LoginViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-09.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIView()
    }
    
    // MARK: Private Functions
    private func setUIView()
    {
        //Setting login button's border and color
        loginButton.layer.borderWidth = 1.5;
        loginButton.layer.cornerRadius = 21.0;
        loginButton.layer.borderColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0).cgColor;
    }


}

