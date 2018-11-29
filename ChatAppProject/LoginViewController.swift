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
    @IBOutlet weak var passwordShowHideImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIView()
    }
    
    
    
    // MARK: Private Functions
    private func setUIView()
    {
        //Setting login button's border and color
        passwordShowHideImage.image = UIImage(named: "passwordHide")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordShowHide))
        passwordShowHideImage.addGestureRecognizer(tapGesture)
        passwordShowHideImage.isUserInteractionEnabled = true;
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
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MessageTableViewController") as! MessageTableViewController
            selfObj.present(nextViewController, animated:true, completion:nil)
        })
    }
    
    @objc func passwordShowHide(){
        if( passwordShowHideImage.image?.isEqual(UIImage(named: "passwordHide")) == true ){
            passwordShowHideImage.image = UIImage(named: "passwordSee")
               txtPassword.clearsOnBeginEditing = false
                txtPassword.isSecureTextEntry = false;
            }
        else{
            txtPassword.clearsOnBeginEditing = false
            txtPassword.isSecureTextEntry = true;
            passwordShowHideImage.image = UIImage(named: "passwordHide")
        }
    }
    class PasswordTextField: UITextField {
        
        override var isSecureTextEntry: Bool {
            didSet {
                if isFirstResponder {
                    _ = becomeFirstResponder()
                }
            }
        }
        
        override func becomeFirstResponder() -> Bool {
            
            let success = super.becomeFirstResponder()
            if isSecureTextEntry, let text = self.text {
                self.text?.removeAll()
                self.text = text
            }
            return success
        }
        
    }
}


