//
//  ComposeViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/3/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit
import RealmSwift

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var replayScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var countCharacterLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var replyToTweet: TweetModel!
    var user: User!
    let realmViewModel = RealmViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConfiguration()
    }
    
    func setupConfiguration() {
        user = realmViewModel.getCurrentUser()
        
        if let url = URL(string: user.profileUrl) {
            photoImageView.setImageWith(url)
        }
        photoImageView.layer.cornerRadius = 5
        photoImageView.clipsToBounds = true
        
        tweetTextView.delegate = self
        tweetTextView.layer.cornerRadius = 5
        tweetTextView.clipsToBounds = true
        
        nameLabel.text = user.name
        
        screenNameLabel.text = "@" + user.screenName
        
        countCharacterLabel.text = "140"
        
        sendButton.layer.cornerRadius = 5
        
        closeButton.layer.cornerRadius = 5
        
        if replyToTweet == nil {
            replayScreenNameLabel.text = ""
        } else {
            replayScreenNameLabel.isHidden = false
            guard let screenName = replyToTweet?.screenname else { return }
            replayScreenNameLabel.text = "@" + screenName + ":"
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "What happened?" {
            textView.text = ""
            textView.textColor = #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1)
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What happened?"
            textView.textColor = #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1)
        }
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        let total = 140 - count
        if total >= 0 {
           countCharacterLabel.text = String(total)
        }
        
        if total <= 0 || total == 140 {
            sendButton.isHidden = true
            countCharacterLabel.textColor = UIColor.red
        } else {
            sendButton.isHidden = false
            countCharacterLabel.textColor = #colorLiteral(red: 0.231372549, green: 0.6, blue: 0.9882352941, alpha: 1)
        }
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        guard var composedText = tweetTextView.text else { return }
        
        if replyToTweet == nil {
            var apiParams: [String: AnyObject] = [:]
            apiParams["status"] = composedText as AnyObject
            
            TwitterClient.sharedInstance?.publishTweet(apiParams: apiParams, completion: { (tweet, error) in
                self.presentViewController()
            })
        } else {
            if let screenName = replyToTweet?.screenname {
                composedText = "@" + screenName + ":" + composedText
            }
                
            TwitterClient.sharedInstance?.replyToTweet(text: composedText, replyToTweetID: replyToTweet?.tweetID, success: { (tweet) in
                self.presentViewController()
            }, failure: {
                print($0)
            })
        }
    }
    
    func presentViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TabViewController") as? UITabBarController {
            self.present(vc, animated: true, completion: nil)
        }
    }

}
