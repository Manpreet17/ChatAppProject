//
//  MessageTableViewCell.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-18.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var toId: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
