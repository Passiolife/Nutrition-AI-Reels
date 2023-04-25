//
//  UITableView+Extention.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 13/04/23.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

extension UITableView {

    func dequeueCell<T: UITableViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable TableView Cell")
        }
        return cell
    }
}

extension UITableViewCell {

    static var identifier: String {
        return String(describing: self)
    }
}
