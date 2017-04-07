//
//  HomeTableViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController, TwitterTableViewDelegate {
    
    var tweets: [TweetModel]?
    var reloadedIndexPaths = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        reloadData()
        setupRefreshControl()
        setupLogo(imageNamed: "Icon-Twitter-1")
    }
    
    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = view.bounds.width
    }
    
    func setupLogo(imageNamed: String) {
        let imageView = UIImageView(image: UIImage(named: imageNamed))
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(HomeTableViewController.reloadData), for: .valueChanged)
        tableView.insertSubview(refreshControl!, at: 0)
    }
    
    func reloadData() {
        TwitterClient.sharedInstance?.homeTimeline(success: { (tweets) in
            DispatchQueue.main.async {
                self.tweets = tweets
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets == nil {
            return 0
        } else {
            return tweets!.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! TweetCompactCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.tweet = tweets?[cell.indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let screenName = tweets?[indexPath.row].screenname else { return }
        openProfile(userScreenName: screenName)
    }
    
    func reloadTableCellAtIndex(cell: UITableViewCell, indexPath: IndexPath) {
        if(reloadedIndexPaths.index(of: indexPath.row) == nil) {
            reloadedIndexPaths.append(indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
}
