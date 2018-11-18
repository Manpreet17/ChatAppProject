//
//  MessageTableViewController.swift
//  ChatAppProject
//
//  Created by Mehak Luthra on 2018-11-18.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class MessageTableViewController: UITableViewController {

    @IBOutlet weak var btnLogout: UIBarButtonItem!
    @IBOutlet weak var txtTitle: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func checkIfUserLoggedIn(){
        let selfObj = self
        //check if user is not logged in
        if Auth.auth().currentUser?.uid == nil{
            logOutUser()
        }
        else{
            let user = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(user!).observeSingleEvent(of: .value, with:  {
                (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    selfObj.txtTitle.title = dictionary["name"] as? String
                }
            })
        }
    }
    
    func logOutUser(){
        do{
            try Auth.auth().signOut()
        }catch let logoutError{
            print(logoutError)
        }
    }
    
    @IBAction func btnLogoutOnClick(_ sender: Any) {
        // logout user
        logOutUser()
        
        // Navigate to Login View Controller
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.destination is LoginViewController
    //        {
    //           logOutUser()
    //        }
    //        else if segue.destination is ChatLogViewController{
    //            print("yes")
    //            guard let chatLogViewController = segue.destination as? ChatLogViewController else {
    //                fatalError("Unexpected destination: \(segue.destination)")
    //            }
    //
    //            guard let selectedUserCell = sender as? UserTableViewCell else {
    //                fatalError("Unexpected sender: \(String(describing: sender))")
    //            }
    //
    //            guard let indexPath = tableView.indexPath(for: selectedUserCell) else {
    //                fatalError("The selected cell is not being displayed by the table")
    //            }
    //
    //            let selectedUser = users[indexPath.row];
    //            chatLogViewController.user = selectedUser;
    //        }
    //    }
}
