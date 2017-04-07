//
//  TweetCell.swift
//  TwitterTest
//
//  Created by Константин on 29.03.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var authorScreennameLabel: UILabel!
    @IBOutlet weak var tweetContentsLabel: UILabel!
    @IBOutlet weak var tweetAgeLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var heightMediaImage: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingMediaImage: NSLayoutConstraint!
    
    var reTweetBool = false
    var favoriteBool = false
    
    weak var delegate: TwitterTableViewDelegate?
    var indexPath: IndexPath!
    
    var tweet: TweetModel! {
        didSet {
            tweetSetConfigure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePictureImageView.layer.cornerRadius = 5
        profilePictureImageView.clipsToBounds = true
        mediaImageView.layer.cornerRadius = 5
        mediaImageView.clipsToBounds = true
    }
    
    func tweetSetConfigure() {
        if let profilePicture = tweet.authorProfilePicURL {
            profilePictureImageView.setImageWith(profilePicture)
        }
        
        authorNameLabel.text = tweet.author
        
        if let screenName = tweet.screenname {
            authorScreennameLabel.text = "@" + screenName
        }
        
        tweetContentsLabel.text = tweet.text
        
        getDate()
        
        if let retweete = tweet.retweeted, let favorited = tweet.favorited {
            retweetButton.isSelected = retweete
            favoriteButton.isSelected = favorited
        }
        
        getHyperlink()
        
        mediaImageView.image = nil
        getMediaImage()
    }
    
    func getDate() {
        DispatchQueue.global(qos: .background).async {
            guard var date = self.tweet.timestamp else { return self.tweetAgeLabel.text = "Unknown date" }
            let firstBound = date.index(date.startIndex, offsetBy: 4)
            let endBound = date.index(date.endIndex, offsetBy: -18)
            date = date.substring(from: firstBound)
            date = date.substring(to: endBound)
            
            DispatchQueue.main.async {
                self.tweetAgeLabel.text = date
            }
        }
    }
    
    func getHyperlink() {
        var displayUrls = [String]()
        
        if let urls = tweet.urls {
            for url in urls {
                if let urltext = url["url"] as? String {
                    tweetContentsLabel.text = tweetContentsLabel.text?.replacingOccurrences(of: urltext, with: "")
                }
                guard var displayurl = url["display_url"] as? String else { return }
                if let expandedURL = url["expanded_url"] {
                    displayurl = expandedURL as! String
                }
                displayUrls.append(displayurl)
            }
        }
        
        if(displayUrls.count > 0){
            let content = tweetContentsLabel.text ?? ""
            
            let urlText = " " + displayUrls.joined(separator: " ")
            
            let text = NSMutableAttributedString(string: content)
            text.addAttribute(NSFontAttributeName,
                              value: UIFont(name: "AppleSDGothicNeo-Thin", size: 17)!,
                              range: NSRange(location: 0, length: content.characters.count))
            
            let links = NSMutableAttributedString(string: urlText)
            links.addAttribute(NSFontAttributeName,
                               value: UIFont(name: "AppleSDGothicNeo-Light", size: 17)!,
                               range: NSRange(location: 0, length: urlText.characters.count))
            links.addAttribute(NSForegroundColorAttributeName,
                               value: #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1),
                               range: NSRange(location: 0, length: urlText.characters.count))
            
            text.append(links)
            tweetContentsLabel.attributedText = text
        }
    }
    
    func getMediaImage() {
        if let media = tweet.media {
            for medium in media {
                let urltext = medium["url"] as! String
                tweetContentsLabel.text = tweetContentsLabel.text?.replacingOccurrences(of: urltext, with: "")
                if (medium["type"] as? String) == "photo" {
                    if let mediaurl = medium["media_url"] as? String {
                        mediaImageView.isHidden = false
                        verticalSpacingMediaImage.constant = 8
                        if heightMediaImage != nil {
                            heightMediaImage.isActive = false
                        }
                        
                        mediaImageView.setImageWith(URLRequest(url:URL(string: mediaurl)!),
                                                    placeholderImage: nil,
                                                    success: { (request, response, image) -> Void in
                            self.mediaImageView.image = image
                            self.delegate?.reloadTableCellAtIndex(cell: self, indexPath: self.indexPath)
                            }, failure: { (request, response, error) -> Void in
                                print(error.localizedDescription)
                        });
                    }
                } else {
                    print("type error")
                }
            }
        } else {
            print("media error")
        }
    }
    
    @IBAction func reTweetAction(_ sender: UIButton) {
        if reTweetBool {
            reTweetBool = false
            tweet.retweeted = false
            retweetCountLabel.text = String(tweet.retweetsCount)
        } else {
            reTweetBool = true
            tweet.retweeted = true
            retweetCountLabel.text = String(tweet.retweetsCount)
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        if favoriteBool {
            favoriteBool = false
            tweet.favorited = false
            favoriteCountLabel.text = String(tweet.favoritesCount)
        } else {
            favoriteBool = true
            tweet.favorited = true
            favoriteCountLabel.text = String(tweet.favoritesCount)
        }
    }
    
    @IBAction func replyButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ComposeViewController") as? ComposeViewController else { return }
        vc.replyToTweet = tweet
        delegate!.openCompose(vc)
    }
}
