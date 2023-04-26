//
//  UIView+Extension.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 13/04/23.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

extension UIView {

    class func fromNib(named: String? = nil) -> Self {
        let name = named ?? "\(Self.self)"
        guard let nib = Bundle.main.loadNibNamed(name, owner: nil, options: nil) else {
            fatalError("missing expected nib named: \(name)")
        }
        /// we're using `first` here because compact map chokes compiler on
        /// optimized release, so you can't use two views in one nib if you wanted to
        /// and are now looking at this
        guard let view = nib.first as? Self else {
            fatalError("view of type \(Self.self) not found in \(nib)")
        }
        return view
    }

    func roundMyCorner() {
        let radius = min(self.bounds.height, self.bounds.width)/2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func roundMyCorenrWith(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        clipsToBounds = true
    }

    func roundMyCornerWith(radius: CGFloat, upper: Bool, down: Bool) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        if upper {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if down {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        self.clipsToBounds = true
    }

    func applyBorder(width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}
