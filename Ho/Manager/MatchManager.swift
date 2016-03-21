//
//  MatchManager.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/13.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import Foundation
import NCMB

protocol MatchManagerDelegate: class {
    func didLoadUserData()
}

class MatchManager: NSObject {
    private let CLASS_NAME = "User"

    static let sharedInstance = MatchManager()
    
    private var userList: [RecommendUser] = []
    
    weak var delegate: MatchManagerDelegate?
    
    override init() {
        super.init()
    }
    func setup() {
        findUser()
    }
    
    func findUser() {
        self.userList = []
        let q = NCMBQuery(className: CLASS_NAME)
        q.limit = 15
        q.whereKey(UserKey.idKey, notEqualTo: UserManager.sharedInstance.currentUser().id)
        
        var list: [String] = []
        list += UserManager.sharedInstance.currentUser().likeUser
        list += UserManager.sharedInstance.currentUser().disLikeUser
        if list.count > 0 {
            q.whereKey(UserKey.idKey, notContainedIn: list)
        }
        
        q.findObjectsInBackgroundWithBlock({
            (array, error) in
            for u in array {
                if let _u = u as? NCMBObject {
                    if  let i = _u.objectForKey(UserKey.idKey) as? String,
                        let f = _u.objectForKey(UserKey.fileUrlKey) as? String,
                        let l = _u.objectForKey(UserKey.likeUserKey) as? [String],
                        let m = _u.objectForKey(UserKey.matchUserKey) as? [String] {
                            
                            let ru = RecommendUser()
                            ru.id = i
                            ru.fileUrl = f
                            ru.likeUser = l
                            ru.matchUser = m
                            
                            self.userList.append(ru)
                    }
                }
            }
            self.delegate?.didLoadUserData()
        })
    }

    
    // TODO: - 課金ユーザー用
    /*
    func findLikeUser() {
        self.userList = []
        let q = NCMBQuery(className: CLASS_NAME)
        q.limit = 5
        q.whereKey(UserKey.likeUserKey, containsAllObjectsInArray: [UserManager.sharedInstance.currentUser().id])
        q.findObjectsInBackgroundWithBlock({
        (array, error) in
            self.userList = [HoUser()]
            self.delegate?.didLoadUserData()
        })
    }
    */
    
    func getRecommendUser() -> [RecommendUser] {
        return self.userList
    }
    
    func setLikeUser(user: RecommendUser, direction: SwipeDirection) -> Bool {
        switch direction {
        case .Left:
            UserManager.sharedInstance.addDisLikeUser(user.id)
            return false
        case .Right:
            UserManager.sharedInstance.addLikeUser(user.id)
            return matchCheck(user)
        }
    }
    
    private func matchCheck(user: RecommendUser) -> Bool {
        if user.matchUser.contains(UserManager.sharedInstance.currentUser().id) {
            return false
        }
        
        if user.likeUser.contains(UserManager.sharedInstance.currentUser().id) {
            print("match!")
            UserManager.sharedInstance.addMatchUser(user.id)
            return true
        }
        
        return false
    }
    
}
enum SwipeDirection {
    case Left
    case Right
}

class RecommendUser {
    var id: String = ""
    var fileUrl: String = ""
    var likeUser: [String] = []
    var matchUser: [String] = []
}
