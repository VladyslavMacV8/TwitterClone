//
//  TweetModel.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation

class TweetModel {
    
    var tweetID: Int?
    var screenname: String?
    var author: String?
    var authorProfilePicURL: URL?
    var text: String?
    var timestamp: String?
    var retweetsCount: Int = 0
    var favoritesCount: Int = 0
    var urls: [[String: AnyObject]]?
    var media: [[String: AnyObject]]?
    
    var favorited: Bool?
    var retweeted: Bool?
    
    init(_ dictionary: [String: AnyObject]) {
        retrieveDataFrom(dictionary)
    }
    
    private func retrieveDataFrom(_ dictionary: [String: AnyObject]) {
        tweetID = dictionary["id"] as? Int ?? 0
        text = dictionary["text"] as? String ?? ""
        retweetsCount = dictionary["retweet_count"] as? Int ?? 0
        favoritesCount = dictionary["favorite_count"] as? Int ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
        timestamp = dictionary["created_at"] as? String ?? ""
        if let dictionary = dictionary["user"] as? [String: AnyObject] {
            screenname = dictionary["screen_name"] as? String ?? ""
            author = dictionary["name"] as? String ?? ""
            authorProfilePicURL = URL(string: dictionary["profile_image_url_https"] as? String ?? "")
        }
        if let dictionary = dictionary["entities"] as? [String: AnyObject] {
            urls = dictionary["urls"] as? [[String: AnyObject]] ?? []
            media = dictionary["media"] as? [[String: AnyObject]] ?? []
        }
    }
    
    class func tweetsWithArray(_ dictionaries: [[String: AnyObject]]) -> [TweetModel] {
        var tweets = [TweetModel]()
        
        for dictionary in dictionaries {
            let tweet = TweetModel(dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
