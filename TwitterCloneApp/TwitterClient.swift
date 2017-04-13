//
//  TwitterClient.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import Foundation
import BDBOAuth1Manager
import RealmSwift

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"),
                                              consumerKey: "cNaxiVQIlmj6Fheu3PQu8j7n2",
                                              consumerSecret: "QlJ0kaeCYDzy2HQRRbI2FqAbqTwUMCXIKozWfFA8MGW0UYJ32B")
    
    private var loginSuccess: (()->())?
    private var loginFailure: ((Error)->())?
    
    let realmViewModel = RealmViewModel()
    
    func login(success: @escaping ()->(), failure: @escaping (Error)->()) {
        
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        
        fetchRequestToken(withPath: "oauth/request_token",
                          method: "GET",
                          callbackURL: URL(string: "twitterTest://oauth"),
                          scope: nil,
                          success: { (requestToken) in
                            
            guard let token = requestToken?.token else { return }
            
            if let url = URL(string: "https://api.twitter.com/oauth/authenticate?oauth_token=" + token) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
                            
            }) { (error) in
                if let error = error { print("Fetch request" + error.localizedDescription) }
        }
    }
    
    func handleOpen(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token",
                         method: "POST",
                         requestToken: requestToken,
                         success: { (accessToken) in
                            
            self.currentAccount({ (user) in
                self.realmViewModel.setCurrentUser(user: user)
                let userDefaults = UserDefaults.standard
                userDefaults.set(user.id, forKey: "id")
                userDefaults.synchronize()
                
                }, failure: { (error) in
                    print("Current Account" + error.localizedDescription)
            })
                            
            self.loginSuccess?()
                            
            }) { (error) in
                if let error = error { self.loginFailure?(error) }
        }
    }
    
    func currentAccount(_ success: @escaping (User)->(), failure: @escaping (Error)->()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let user = User(dictionary)
            success(user)
            }) { (task, error) in
                failure(error)
        }
    }
    
    func homeTimeline(_ success: @escaping ([TweetModel]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: ["count": 30], progress: nil, success: { (task, response) in
            guard let dictionaries = response as? [[String: AnyObject]] else { return }
            let tweets = TweetModel.tweetsWithArray(dictionaries)
            success(tweets)
            }) { (task, error) in
                failure(error)
        }
    }
    
    func userTimeline(user: User, success: @escaping ([TweetModel]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/user_timeline.json", parameters: ["count": 25, "user_id": user.id], progress: nil, success: { (task, response) in
            guard let dictionaries = response as? [[String: AnyObject]] else { return }
            let tweets = TweetModel.tweetsWithArray(dictionaries)
            success(tweets)
            }) { (task, error) in
                failure(error)
        }
    }
    
    func getUserByScreenname(screenname: String, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/users/lookup.json?screen_name=" + screenname, parameters: nil, progress: nil, success: { (task, response) in
            guard let dictionaries = response as? [[String: AnyObject]] else { return }
            let user = User(dictionaries[0])
            success(user)
            }) { (task, error) in
                failure(error)
        }
    }
    
    func retweet(params: [String: AnyObject]?, retweet: Bool, completion: @escaping (_ tweet: TweetModel?, _ error: Error?) -> ()) {
        let tweetId = params!["id"] as! Int
        let endpoint = retweet ? "retweet" : "unretweet"
        post("1.1/statuses/\(endpoint)/\(tweetId).json", parameters: ["id": tweetId], progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let tweet = TweetModel(dictionary)
            completion(tweet, nil)
            }) { (task, error) in
                completion(nil, error)
        }
    }
    
    func favorite(params: [String: AnyObject]?, favorite: Bool, completion: @escaping (_ tweet: TweetModel?, _ error: Error?) -> ()) {
        let endpoint = favorite ? "create" : "destroy"
        post("1.1/favorites/\(endpoint).json", parameters: params, progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let tweet = TweetModel(dictionary)
            completion(tweet, nil)
            }) { (task, error) in
                completion(nil, error)
        }
    }
    
    func publishTweet(apiParams: [String: AnyObject], completion: @escaping (_ newTweet: TweetModel?, _ error: Error?) -> ()) {
        post("1.1/statuses/update.json", parameters: apiParams, progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let tweet = TweetModel(dictionary)
            completion(tweet, nil)
            }) { (task, error) in
                completion(nil, error)
        }
    }
    
    func replyToTweet(text: String, replyToTweetID: Int? = 0, success: @escaping (TweetModel) -> (), failure: @escaping (Error) -> ()) {
        if text == "" { return }
        post("1.1/statuses/update.json", parameters: ["status": text, "in_reply_to_status_id": replyToTweetID!], progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let tweet = TweetModel(dictionary)
            success(tweet)
            }) { (task, error) in
                failure(error)
        }
    }
    
    func deleteTweet(tweetId: String, completion: @escaping (_ tweet: TweetModel?, _ error: Error?) -> ()) {
        post("1.1/statuses/destroy/\(tweetId).json", parameters: nil, progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let tweet = TweetModel(dictionary)
            completion(tweet, nil)
            }) { (task, error) in
                completion(nil, error)
        }
    }
    
    func searchNewUser(query: String, success: @escaping ([NewUserModel]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/users/search.json", parameters: ["q": query], progress: nil, success: { (task, response) in
            guard let dictionaries = response as? [[String: AnyObject]] else { return }
            let user = NewUserModel.usersWithArray(dictionaries)
            success(user)
            }) { (task, error) in
                failure(error)
        }
    }
    
    func followNewUser(screenName: String, completion: @escaping (_ newTweet: NewUserModel?, _ error: Error?) -> ()) {
        post("1.1/friendships/create.json", parameters: ["screen_name": screenName, "follow": true], progress: nil, success: { (task, response) in
            guard let dictionary = response as? [String: AnyObject] else { return }
            let followUser = NewUserModel(dictionary)
            completion(followUser, nil)
            }) { (task, error) in
                completion(nil, error)
        }
    }

    func logout() {
        deauthorize()
        realmViewModel.deleteCurrentUser()
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
