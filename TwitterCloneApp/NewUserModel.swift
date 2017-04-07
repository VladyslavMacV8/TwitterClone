//
//  NewUser.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

class NewUserModel {
    var name: String?
    var screenName: String?
    var photoURL: URL?
    var following: Bool?
    
    init(_ dictionary: [String: AnyObject]) {
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        guard let photoString = dictionary["profile_image_url_https"] as? String else { return }
        photoURL = URL(string: photoString)
        following = dictionary["following"] as? Bool
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