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
    var urls: [[String: AnyObject]]?
    var media: [[String: AnyObject]]?
    var text: String?
    var timestamp: String?
    var retweetsCount: Int = 0
    var favoritesCount: Int = 0
    
    var favorited: Bool? {
        didSet {
            if favorited! {
                TwitterClient.sharedInstance?.favorite(params: ["id": tweetID as AnyObject],
                                                       favorite: true,
                                                       completion: { (tweet, error) in })
                self.favoritesCount += 1
            } else {
                TwitterClient.sharedInstance?.favorite(params: ["id": tweetID as AnyObject],
                                                       favorite: false,
                                                       completion: { (tweet, error) in })
                self.favoritesCount -= 1
            }
        }
    }
    
    var retweeted: Bool? {
        didSet {
            if retweeted! {
                TwitterClient.sharedInstance?.retweet(params: ["id": tweetID as AnyObject],
                                                      retweet: true,
                                                      completion: { (tweet, error) in })
                self.retweetsCount += 1
            } else {
                TwitterClient.sharedInstance?.retweet(params: ["id": tweetID as AnyObject],
                                                      retweet: false,
                                                      completion: { (tweet, error) in })
                self.retweetsCount -= 1
            }
        }
    }
    
    init(_ dictionary: [String: AnyObject]) {
        retrieveDataFrom(dictionary)
    }
    
    private func retrieveDataFrom(_ dictionary: [String: AnyObject]) {
        tweetID = dictionary["id"] as? Int ?? 0
        screenname = dictionary["user"]!["screen_name"] as? String ?? ""
        author = dictionary["user"]!["name"] as? String ?? ""
        authorProfilePicURL = URL(string: dictionary["user"]!["profile_image_url_https"] as? String ?? "")
        text = dictionary["text"] as? String ?? ""
        retweetsCount = dictionary["retweet_count"] as? Int ?? 0
        favoritesCount = dictionary["favorite_count"] as? Int ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
        timestamp = dictionary["created_at"] as? String ?? ""
        urls = dictionary["entities"]?["urls"] as? [[String: AnyObject]] ?? []
        media = dictionary["entities"]?["media"] as? [[String: AnyObject]] ?? []
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
