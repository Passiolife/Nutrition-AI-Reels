//
//  UICollectionView+Extension.swift
//  NaiyaApp
//
//  Created by Nikunj Prajapti on 22/02/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

extension UICollectionView {

    func dequeueCell<T: UICollectionViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable CollectionView Cell")
        }
        return cell
    }
}

extension UICollectionReusableView {

    static var identifier: String {
        return String(describing: self)
    }
}
