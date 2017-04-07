//
//  ViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 3/28/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.layer.cornerRadius = 5
        logInButton.clipsToBounds = true
    }
    
    @IBAction func connection(_ sender: UIButton) {
        TwitterClient.sharedInstance?.login(success: {
            self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print(error.localizedDescription)
        })
    }
}

