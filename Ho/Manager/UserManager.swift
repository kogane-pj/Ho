//
//  UserManager.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/09.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    func isLogin() -> Bool {
        return NCMBUser.currentUser() != nil
    }

    func signUp(name: String, password: String) -> Bool {
        let user = NCMBUser()
        user.userName = name
        user.password = password
        
        var error: NSError? = nil
        user.signUp(&error)
        return error == nil
    }
}

class HoUser: NCMBUser {
}
