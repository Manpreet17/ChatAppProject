//
//  RegisterViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-10.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIView()
    }
    
    // MARK: Private Functions
    private func setUIView()
    {
        //Setting register button border and color
        registerButton.layer.borderWidth = 1.5;
        registerButton.layer.cornerRadius = 21.0;
        registerButton.layer.borderColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0).cgColor;
    }

}
