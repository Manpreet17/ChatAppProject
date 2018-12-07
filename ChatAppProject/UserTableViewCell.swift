//
//  UserTableViewCell.swift
//  ChatAppProject
//
//  Created by Mehak Luthra on 2018-11-17.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    

    @IBOutlet weak var inage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
