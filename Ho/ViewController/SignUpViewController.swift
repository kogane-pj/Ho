//
//  SignUpViewController.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/05.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var isNameLimit: Bool = false
    var isPassLimit: Bool = false
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func didPushSignUp(sender: AnyObject) {
//        if let name = self.nameField.text, let pass = self.passField.text {
//            let result = UserManager.sharedInstance.signUp(name, password: pass)
//            print(result)
//            if result == true {
//                self.dismissViewControllerAnimated(false, completion: nil)
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if !UserManager.sharedInstance.isNew() {
//            self.signUpButton.setTitle("Login", forState: .Normal)
//        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newLength = text.utf16.count + string.utf16.count - range.length
            switch textField.tag {
            case 1:
                self.isNameLimit = newLength > 0
                break
            case 2:
                self.isPassLimit = newLength > 0
                break
            default:
                break
            }
            self.signUpButton.enabled = self.isNameLimit && self.isPassLimit
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
