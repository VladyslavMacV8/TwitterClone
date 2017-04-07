//
//  ProfileViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/31/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TwitterTableViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var user: User!
    var userScreenName: String!
    var refreshControl: UIRefreshControl!
    var tweets: [TweetModel]?
    var reloadedIndexPaths = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        User.tempUser = nil
        if userScreenName == nil {
            guard let currentUser = User.currentUser else { return }
            user = currentUser
            setupViewController()
        } else {
            TwitterClient.sharedInstance?.getUserByScreenname(screenname: userScreenName!, success: { (user) in
                User.tempUser = user
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProfileConfigureView"), object: nil)
            }, failure: { (error) in })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProfileConfigureView"),
                                               object: nil,
                                               queue: OperationQueue.main) { (notification) in
                                                
            self.user = User.tempUser
            self.setupViewController()
        }
    }
    
    func setupViewController() {
        if let backgorundImageUrl = user.backgroundImageURL {
            backgroundImageView.setImageWith(URL(string: backgorundImageUrl)!)
            if user.usingBannerImage != true {
                backgroundImageView.contentMode = .scaleAspectFill
            } else {
                backgroundImageView.contentMode = .redraw
            }
        }
        
        profileImageView.setImageWith(user.profileUrl!)
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 5
        
        nameLabel.text = user.name
        
        screenNameLabel.text = "@" + user.screenname!
        
        followersCountLabel.text = user.followersCount?.description
        followingCountLabel.text = user.followingCount?.description
        
        closeButton.layer.cornerRadius = closeButton.frame.height / 4
        closeButton.clipsToBounds = true
        
        if user.screenname != User.currentUser?.screenname {
            logOutButton.isHidden = true
            closeButton.isHidden = false
        } else {
            logOutButton.isHidden = false
            closeButton.isHidden = true
        }
        
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.rowHeight = UITableViewAutomaticDimension
        userTableView.estimatedRowHeight = view.bounds.width
        userTableView.allowsSelection = false
        
        reloadData()
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProfileViewController.reloadData), for: .valueChanged)
        userTableView.insertSubview(refreshControl!, at: 0)
    }
    
    func reloadData() {
        TwitterClient.sharedInstance?.userTimeline(user: user, success: { (tweets) in
            self.tweets = tweets
            self.userTableView.reloadData()
            self.refreshControl?.endRefreshing()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets == nil {
            return 0
        } else {
            return tweets!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! TweetCompactCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.tweet = tweets?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if userScreenName == nil {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tweet = tweets?[indexPath.row]
            guard let tweetID = tweet?.tweetID.description else { return }
            TwitterClient.sharedInstance?.deleteTweet(tweetId: tweetID, completion: { (tweet, error) in
                self.reloadData()
            })
        }
    }
    
    func reloadTableCellAtIndex(cell: UITableViewCell, indexPath: IndexPath) {
        if(reloadedIndexPaths.index(of: indexPath.row) == nil) {
            reloadedIndexPaths.append(indexPath.row)
            DispatchQueue.main.async {
                self.userTableView.reloadData()
            }
        }
    }
    
    func openProfile(userScreenName: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! UINavigationController
        let pVC = vc.viewControllers.first as! ProfileViewController
        pVC.userScreenName = userScreenName
        self.present(vc, animated: true, completion: nil)
    }
    
    func openCompose(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    @IBAction func logOutButtonAction(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(cancelActionButton)
        let logOutActionButton = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
            TwitterClient.sharedInstance?.logout()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! ZeroViewController
            self.present(vc, animated: true, completion: nil)
        }
        actionSheetController.addAction(logOutActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
