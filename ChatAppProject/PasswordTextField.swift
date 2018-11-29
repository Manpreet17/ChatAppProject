//
//  PasswordTextField.swift
//  ChatAppProject
//
//  Created by Mehak Luthra on 2018-11-29.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit

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
            deleteBackward()
            insertText(text)
        }
        return success
    }
    
}
