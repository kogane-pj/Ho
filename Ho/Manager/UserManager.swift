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
    struct Key {
        static let USER_KEY = "UserKey"
    }
    
    weak var delegate: UserManagerDelegate?
        
    func currentUser() -> HoUser {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(Key.USER_KEY) as? NSData {
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
        return currentUser().fileUrl != ""
    }

    func updateHo(fileName: String, url: NSURL) -> Bool {
        if let _ = FileManager.sharedInstance.uploadFile(fileName, url: url, defaultUrl: nil) {
            let user = currentUser()
            user.fileUrl = fileName
            user.setObject(fileName, forKey: UserKey.fileUrlKey)
            return saveUser(user)
        }
        
        return false
    }
    
    func addLikeUser(userId: String) {
        let user = currentUser()
        user.likeUser.append(userId)
        user.setObject(user.likeUser, forKey: UserKey.likeUserKey)
        backgroundSaveUser(user)
    }
    func addDisLikeUser(userId: String) {
        let user = currentUser()
        user.disLikeUser.append(userId)
        user.setObject(user.disLikeUser, forKey: UserKey.disLikeUserKey)
        backgroundSaveUser(user)
    }
    func addMatchUser(userId: String) {
        let user = currentUser()
        user.matchUser.append(userId)
        user.setObject(user.matchUser, forKey: UserKey.matchUserKey)
        backgroundSaveUser(user)
    }
    
    private func saveUser(user: HoUser) -> Bool {
        var error: NSError?
        user.save(&error)
        if error == nil {
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(user)
            NSUserDefaults.standardUserDefaults().setObject(encodedData, forKey: Key.USER_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
            self.keychain[KeychainUserKey.objectIdKey] = user.objectId
            self.delegate?.refreshUserInfo()
        }
        else {
            self.keychain[KeychainUserKey.objectIdKey] = nil
        }
        
        return error == nil
    }
    
    private func backgroundSaveUser(user: HoUser) {
        user.saveInBackgroundWithBlock({ error in
            if error == nil {
                let encodedData = NSKeyedArchiver.archivedDataWithRootObject(user)
                NSUserDefaults.standardUserDefaults().setObject(encodedData, forKey: Key.USER_KEY)
                NSUserDefaults.standardUserDefaults().synchronize()
                self.keychain[KeychainUserKey.objectIdKey] = user.objectId
                self.delegate?.refreshUserInfo()
            }
            else {
                self.keychain[KeychainUserKey.objectIdKey] = nil
            }
        })
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
    var likeUser: [String] = [] {
        didSet {
            self.setObject(likeUser, forKey: UserKey.likeUserKey)
        }
    }
    var disLikeUser: [String] = [] {
        didSet {
            self.setObject(disLikeUser, forKey: UserKey.disLikeUserKey)
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
        if let l = aDecoder.decodeObjectForKey(UserKey.likeUserKey) as? [String] {
            self.likeUser = l
            self.setObject(l, forKey: UserKey.likeUserKey)
        }
        if let d = aDecoder.decodeObjectForKey(UserKey.disLikeUserKey) as? [String] {
            self.disLikeUser = d
            self.setObject(d, forKey: UserKey.disLikeUserKey)
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
        aCoder.encodeObject(likeUser, forKey: UserKey.likeUserKey)
        aCoder.encodeObject(disLikeUser, forKey: UserKey.disLikeUserKey)
        aCoder.encodeObject(matchUser, forKey: UserKey.matchUserKey)
    }
}

struct KeychainUserKey {
    static let idKey: String            = "USER_ID"
    static let objectIdKey: String      = "OBJECT_ID"
}

struct UserKey {
    static let objIdKey: String         = "objectId"
    static let idKey: String            = "id"
    static let fileUrlKey: String       = "fileUrl"
    static let likeUserKey: String      = "likeUser"
    static let disLikeUserKey: String   = "disLikeUser"
    static let matchUserKey: String     = "matchUser"
}
