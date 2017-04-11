//
//  ZeroViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/29/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class ZeroViewController: UIViewController, TwitterLoginDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        TwitterClient.sharedInstance?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !appDelegate.splashDelay {
            delay(1.0, completion: { 
                self.continueLogin()
            })
        }
    }
    
    func continueLogin() {
        appDelegate.splashDelay = false
        if User.currentUser == nil {
            self.performSegue(withIdentifier: "toLog", sender: self)
        } else {
            self.performSegue(withIdentifier: "toHome", sender: self)
        }
    }

}
