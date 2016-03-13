//
//  UserManager.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/09.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB
import KeychainAccess

protocol UserManagerDelegate: class {
    func refreshUserInfo()
}

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    private let keychain = Keychain(service: "com.koganepj.Ho")
    private let USER_KEY = "UserKey"
    
    weak var delegate: UserManagerDelegate?
        
    func currentUser() -> HoUser {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(USER_KEY) as? NSData {
            if let user = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? HoUser {
                return user
            }
        }
        
        let _user = HoUser()
        if let userID = keychain[KeychainUserKey.idKey] {
            _user.id = userID
        }
        else {
            _user.id = NSUUID().UUIDString
            keychain[KeychainUserKey.idKey] = _user.id
        }
        if let objectID = keychain[KeychainUserKey.objectIdKey] {
            _user.objectId = objectID
        }
        
        saveUser(_user)
        return _user
    }
    
    func hasHoFile() -> Bool {
        return false
    }

    func updateHo(fileName: String, url: NSURL) {
        if let _url = FileManager.sharedInstance.uploadFile(fileName, url: url, defaultUrl: nil) {
            let user = currentUser()
            user.fileUrl = _url.description
            user.setObject(_url.description, forKey: UserKey.fileUrlKey)
            saveUser(user)
        }
    }
    
    private func saveUser(user: HoUser) {
        var error: NSError?
        user.save(&error)
        if error == nil {
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(user)
            NSUserDefaults.standardUserDefaults().setObject(encodedData, forKey: USER_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
            keychain[KeychainUserKey.objectIdKey] = user.objectId
            self.delegate?.refreshUserInfo()
        }
        else {
            keychain[KeychainUserKey.objectIdKey] = nil
        }
    }
}

class HoUser: NCMBObject, NSCoding {
    private let CLASS_NAME = "User"
    
    var id: String = "" {
        didSet {
            self.setObject(id, forKey: UserKey.idKey)
        }
    }
    var fileUrl: String = "" {
        didSet {
            self.setObject(fileUrl, forKey: UserKey.fileUrlKey)
        }
    }
    var watchUser: [String] = [] {
        didSet {
            self.setObject(watchUser, forKey: UserKey.watchUserKey)
        }
    }
    var matchUser: [String] = [] {
        didSet {
            self.setObject(matchUser, forKey: UserKey.matchUserKey)
        }
    }
    
    override init() {
        super.init(className: CLASS_NAME)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(className: CLASS_NAME)
        
        if let o = aDecoder.decodeObjectForKey(UserKey.objIdKey) as? String {
            self.objectId = o
        }
        if let i = aDecoder.decodeObjectForKey(UserKey.idKey) as? String {
            self.id = i
            self.setObject(i, forKey: UserKey.idKey)
        }
        if let f = aDecoder.decodeObjectForKey(UserKey.fileUrlKey) as? String {
            self.fileUrl = f
            self.setObject(f, forKey: UserKey.fileUrlKey)
        }
        if let w = aDecoder.decodeObjectForKey(UserKey.watchUserKey) as? [String] {
            self.watchUser = w
            self.setObject(w, forKey: UserKey.watchUserKey)
        }
        if let m = aDecoder.decodeObjectForKey(UserKey.matchUserKey) as? [String] {
            self.matchUser = m
            self.setObject(m, forKey: UserKey.matchUserKey)
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectId, forKey: UserKey.objIdKey)
        aCoder.encodeObject(id, forKey: UserKey.idKey)
        aCoder.encodeObject(fileUrl, forKey: UserKey.fileUrlKey)
        aCoder.encodeObject(watchUser, forKey: UserKey.watchUserKey)
        aCoder.encodeObject(matchUser, forKey: UserKey.matchUserKey)
    }
}

struct KeychainUserKey {
    static let idKey: String            = "USER_ID"
    static let objectIdKey: String      = "OBJECT_ID"
}

struct UserKey {
    static let objIdKey: String     = "objectId"
    static let idKey: String        = "id"
    static let fileUrlKey: String   = "fileUrl"
    static let watchUserKey: String = "watchUser"
    static let matchUserKey: String = "matchUser"
}
