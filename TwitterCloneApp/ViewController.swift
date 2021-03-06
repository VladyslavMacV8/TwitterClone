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
        logInButton.isHidden = true
        TwitterClient.sharedInstance?.login(success: {
                self.performSegue(withIdentifier: "toHome", sender: self)
            }, failure: { (error) in
                print(error.localizedDescription)
        })
    }
}

