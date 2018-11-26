//
//  Message.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-18.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject{
    var fromId: String?
    var toId: String?
    var text: String?
    var latitude: Double?
    var longitude: Double?
    var timestamp: NSNumber?
    
    func partnerId() -> String?{
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
