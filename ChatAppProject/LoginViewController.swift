//
//  LoginViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-09.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
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
    
    
    @IBAction func btnLoginOnClick(_ sender: Any) {
        let selfObj = self
        guard let email = txtEmail.text, let password = txtPassword.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            
            if error != nil
            {
                print(error!)
                return
            }
                //Login successful 
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MessageTableView") as! MessageTableViewController
            selfObj.present(nextViewController, animated:true, completion:nil)
        })
    }
    


}

