//
//  SearchTableViewController.swift
//  TwitterCloneApp
//
//  Created by Vladyslav Kudelia on 4/4/17.
//  Copyright © 2017 Vladyslav Kudelia. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!

    var newUsers: [NewUserModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        tableView.allowsSelection = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TwitterClient.sharedInstance?.currentAccount({ (user) in
            TwitterClient.sharedInstance?.user = user
        }, failure: { (error) in
            print(error)
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newUsers == nil ? 0 : newUsers!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchTableViewCell
        cell.buttonTap = {
            self.reloadData()
        }
        cell.newUser = self.newUsers?[indexPath.row]
        return cell
    }
    
    func reloadData() {
        TwitterClient.sharedInstance?.searchNewUser(query: searchTextField.text!, success: { (newUsers) in
            self.newUsers = newUsers
            self.tableView.reloadData()
        }, failure: { (error) in
            print(error)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func searchBarButtonAction(_ sender: UIBarButtonItem) {
        guard let count = searchTextField.text?.characters.count else { return }
        if count > 2 && count < 15 {
            reloadData()
        }
    }
}
