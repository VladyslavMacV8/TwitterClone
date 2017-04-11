//
//  TweetCompactCell.swift
//  TwitterTest
//
//  Created by Константин on 29.03.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import UIKit

class TweetCompactCell: TweetCell {
    override func tweetSetConfigure() {
        super.tweetSetConfigure()
        
        retweetCountLabel.text = tweet.retweetsCount > 0 ? String(tweet.retweetsCount) : String(0)
        favoriteCountLabel.text = tweet.favoritesCount > 0 ? String(tweet.favoritesCount) : String(0)
    }
}
