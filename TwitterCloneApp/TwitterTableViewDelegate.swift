//
//  TwitterTableViewDelegate.swift
//  TwitterTest
//
//  Created by Константин on 30.03.16.
//  Copyright © 2016 Константин. All rights reserved.
//

import UIKit

protocol TwitterTableViewDelegate: class,  UITableViewDelegate {
    func reloadTableCellAtIndex(cell: UITableViewCell, indexPath: IndexPath)
    func openProfile(userScreenName: String)
    func openCompose(_ viewController: UIViewController)
}
