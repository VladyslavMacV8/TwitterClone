//
//  UseModel.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

class User {
 
    var dictionary: [String: AnyObject]?
    var id: Int?
    var name: String?
    var screenName: String?
    var profileUrl: URL?
    var backgroundImageURL: String?
    var usingBannerImage = true
    var followersCount: Int?
    var followingCount: Int?
    
    init(_ dictionary: [String: AnyObject]) {
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
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String ?? ""
        profileUrl = URL(string: profileUrlString)
        
        followersCount = dictionary["followers_count"] as? Int ?? 0
        followingCount = dictionary["friends_count"] as? Int ?? 0
    }
}
