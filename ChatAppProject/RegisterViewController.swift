//
//  RegisterViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-10.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var reenterPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var reenterPasswordHideShowImage: UIImageView!
    @IBOutlet weak var passwordHideShowImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIView()
    }
    
    // MARK: Private Functions
    private func setUIView()
    {
        //Setting register button border and color
        passwordHideShowImage.image = UIImage(named: "passwordHide")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordShowHide))
        passwordHideShowImage.addGestureRecognizer(tapGesture)
        passwordHideShowImage.isUserInteractionEnabled = true;
        reenterPasswordHideShowImage.image = UIImage(named: "passwordHide")
        let tapGestureRenter = UITapGestureRecognizer(target: self, action: #selector(reeneterPasswordShowHide))
        reenterPasswordHideShowImage.addGestureRecognizer(tapGestureRenter)
        reenterPasswordHideShowImage.isUserInteractionEnabled = true;
        registerButton.layer.borderWidth = 1.5;
        registerButton.layer.cornerRadius = 21.0;
        registerButton.layer.borderColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0).cgColor;
    }

    @IBAction func btnRegisterOnClick(_ sender: Any) {
        let selfObj = self
        if(selfObj.checkErrorCases()){
            guard let email = txtEmail.text, let password = txtPassword.text else {
                return
            }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil
            {
                // if error in registering
                print(error!)
                return
            }
            guard let uid = authResult?.user.uid else {
                return
            }
        
            // user successfully authenticated
            // adding users to database
            let ref = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/")
            let userRef = ref.child("users").child(uid)
            let values = ["name":self.txtUsername.text, "email":self.txtEmail.text]
            userRef.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err!)
                    return
                }
                print("user is saved successfully into database")
                 selfObj.registerOnSuccess()
    
            })
        }
        }
        
    }
    func registerOnSuccess(){
        let selfObj = self
        let alert = UIAlertController(title: "Sucessfully Registered!", message: "Congrats! You have been successfully registered. Please Login to use chat app.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction!) in
            selfObj.navigateToLoginScreen()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    func checkErrorCases()->Bool{
        if(txtEmail.text==""||reenterPassword.text==""||txtPassword.text==""||txtUsername.text==""){
            let alert = UIAlertController(title: "Error", message: "All the feilds are mandatory.Please specify all the fields", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              self.present(alert, animated: true, completion: nil)
            return false
        }
        else if(!emailValidate(email: txtEmail.text!)){
            let alert = UIAlertController(title: "Error", message: "Email is not in the correct format", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if(reenterPassword.text != txtPassword.text){
            let alert = UIAlertController(title: "Error", message: "Passwords don't match", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else if((txtPassword.text?.count)!<6){
            let alert = UIAlertController(title: "Error", message: "Password must be atleast 6 characters long", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
       
    }
    func emailValidate(email:String) -> Bool {
        
        let formatOfEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", formatOfEmail)
        return predicate.evaluate(with: email)
        
    }
    func navigateToLoginScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    @objc func passwordShowHide(){
        if( passwordHideShowImage.image?.isEqual(UIImage(named: "passwordHide")) == true ){
            passwordHideShowImage.image = UIImage(named: "passwordSee")
            txtPassword.clearsOnBeginEditing = false
            txtPassword.isSecureTextEntry = false;
        }
        else{
            txtPassword.clearsOnBeginEditing = false
            txtPassword.isSecureTextEntry = true;
            passwordHideShowImage.image = UIImage(named: "passwordHide")
        }
    }
    @objc func reeneterPasswordShowHide(){
        if( reenterPasswordHideShowImage.image?.isEqual(UIImage(named: "passwordHide")) == true ){
            reenterPasswordHideShowImage.image = UIImage(named: "passwordSee")
            reenterPassword.clearsOnBeginEditing = false
            reenterPassword.isSecureTextEntry = false;
        }
        else{
            reenterPassword.clearsOnBeginEditing = false
            reenterPassword.isSecureTextEntry = true;
            reenterPasswordHideShowImage.image = UIImage(named: "passwordHide")
        }
    }
}
