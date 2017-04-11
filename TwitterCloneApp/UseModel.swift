//
//  UseModel.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

class User {
    static let userDidLogoutNotification = "UserDidLogout"
    static var user: User?
    static var tempUser: User?
    
    var dictionary: [String: AnyObject]?
    var id: Int?
    var name: String?
    var screenname: String?
    var profileUrl: URL?
    var backgroundImageURL: String?
    var usingBannerImage = true
    var followersCount: Int?
    var followingCount: Int?
    
    class var currentUser: User? {
        get {
            let defaults = UserDefaults.standard
            
            if user == nil {
                let userData = defaults.object(forKey: "currentUser") as? Data
                if let userData = userData {
                    do {
                        let dict = try JSONSerialization.jsonObject(with: userData, options: []) as! [String: AnyObject]
                        user = User(dict)
                    } catch {
                        print("User nil")
                    }
                }
            }
            return user
        } set(user) {
            self.user = user
            let defaults = UserDefaults.standard
            
            if let user = user {
                guard let dictionary = user.dictionary else { return }
                let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.set(nil, forKey: "currentUser")
            }
        }
    }
    
    init(_ dictionary: [String: AnyObject]) {
        self.dictionary = dictionary
        retrieveDataFrom(dictionary)
    }
    
    fileprivate func retrieveDataFrom(_ dictionary: [String: AnyObject]) {
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        screenname = dictionary["screen_name"] as? String ?? ""
        
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
