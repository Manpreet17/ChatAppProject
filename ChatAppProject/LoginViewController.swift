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
       // setupKeyBoardObserver()
       }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
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
        if(txtEmail.text==""||txtPassword.text==""){
            selfObj.handleEmptyFields()
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (user, error) in
            
            if error != nil
            {
                if( (error?._code)! == 17011){
                    selfObj.hanleUserNotFound()
                }
                else if( (error?._code)! == 17008){
                    selfObj.handleInvalidEmail()
                }
                else if( (error?._code)! == 17009){
                  selfObj.handleWrongPassword()
                }
                else{
                    let alert = UIAlertController(title: "Error Loggin in!", message: "Unexpected error occurred, Please try again", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    selfObj.txtEmail.text = ""
                    selfObj.txtPassword.text=""
                }
//                if let error1 = AuthErrorCode(rawValue: (error?._code)!) {
//                    _ =  type(of: (error?._code)!)
//                    print("---error1   \(String(describing: error?._code))!")
//                    print(error)
//                    return
            //}
            }
                //Login successful 
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MessageTableViewController") as! MessageTableViewController
            selfObj.present(nextViewController, animated:true, completion:nil)
        })
    }
    
    func handleEmptyFields(){
        let alert = UIAlertController(title: "Error!", message: "All the feilds are mandatory.Please specify all the fields", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func handleInvalidEmail(){
        let selfObj = self
        let alert = UIAlertController(title: "Invalid email!", message: "Please enter valid email id", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction!) in
            selfObj.txtEmail.text = ""
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func hanleUserNotFound(){
        let selfObj = self
        let alert = UIAlertController(title: "User not found!", message: "Please register yourself if you are not registered", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction!) in
            selfObj.txtEmail.text = ""
            selfObj.txtPassword.text = ""
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func handleWrongPassword(){
        let selfObj = self
        let alert = UIAlertController(title: "Wrong Password!", message: "Please enter your password again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) in
            selfObj.txtPassword.text = ""
    }))
        self.present(alert, animated: true, completion: nil)
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
    func setupKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func handleKeyboardShow(notification : NSNotification){
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        self.view.window?.frame.origin.y = -(keyboardFrame!.height-200)
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    @objc func handleKeyboardHide(notification : NSNotification){
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        self.view.window?.frame.origin.y = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
}


