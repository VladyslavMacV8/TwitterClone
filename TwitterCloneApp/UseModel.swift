//
//  UseModel.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
 
    var dictionary: [String: AnyObject] = [:]
    
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var screenName: String = ""
    dynamic var profileUrl: String = ""
    dynamic var backgroundImageURL: String?
    dynamic var usingBannerImage = true
    dynamic var followersCount: Int = 0
    dynamic var followingCount: Int = 0
    
    convenience init(_ dictionary: [String: AnyObject]) {
        self.init()
        self.dictionary = dictionary
        retrieveDataFrom(dictionary)
    }
    
    fileprivate func retrieveDataFrom(_ dictionary: [String: AnyObject]) {
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        screenName = dictionary["screen_name"] as? String ?? ""
        
        backgroundImageURL = dictionary["profile_banner_url"] as? String
        if(backgroundImageURL != nil) {
            backgroundImageURL?.append("/600x200")
        } else {
            backgroundImageURL = dictionary["profile_background_image_url_https"] as? String ?? ""
            usingBannerImage = false
        }
        
        profileUrl = dictionary["profile_image_url_https"] as? String ?? ""
        
        followersCount = dictionary["followers_count"] as? Int ?? 0
        followingCount = dictionary["friends_count"] as? Int ?? 0
    }
    
    override static func ignoredProperties() -> [String] {
        return ["dictionary"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
