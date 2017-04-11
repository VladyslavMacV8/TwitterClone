//
//  NewUser.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

class NewUserModel: User {
    
    var following: Bool?
    
    override init(_ dictionary: [String: AnyObject]) {
        super.init(dictionary)
        name = dictionary["name"] as? String ?? ""
        screenName = dictionary["screen_name"] as? String ?? ""
        profileUrl = URL(string: dictionary["profile_image_url_https"] as? String ?? "")
        following = dictionary["following"] as? Bool ?? false
    }
    
    class func usersWithArray(_ dictionaries: [[String: AnyObject]]) -> [NewUserModel] {
        var users = [NewUserModel]()
        
        for dictionary in dictionaries {
            let user = NewUserModel(dictionary)
            users.append(user)
        }
        
        return users
    }
}
