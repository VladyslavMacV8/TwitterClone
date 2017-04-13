//
//  SearchTableViewCell.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var buttonTap:(()->())?
    
    var newUser: NewUserModel! {
        didSet {
            newUserSetConfigure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = 5
        photoImageView.clipsToBounds = true
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
    }
    
    func newUserSetConfigure() {
        if let url = URL(string: newUser.profileUrl) {
            photoImageView.setImageWith(url)
        }
        
        nameLabel.text = newUser.name
        
        screenNameLabel.text = "@" + newUser.screenName
        
        updateFollowing()
    }
    
    func updateFollowing() {
        if !newUser.following! {
            followButton.isHidden = false
        } else {
            followButton.isHidden = true
        }
    }
    
    @IBAction func followButtonAction(_ sender: UIButton) {
        TwitterClient.sharedInstance?.followNewUser(screenName: newUser.screenName, completion: { (newFollowUser, error) in })
        buttonTap?()
        followButton.isHidden = true
    }
}
