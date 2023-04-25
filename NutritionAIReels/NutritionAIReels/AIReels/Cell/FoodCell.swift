//
//  FoodCell.swift
//  NaiyaApp
//
//  Created by Nikunj Prajapati on 23/02/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

final class FoodCell: UITableViewCell {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurButtonView: UIVisualEffectView!
    @IBOutlet weak var foodView: UIView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        foodView.roundMyCorenrWith(radius: 8)
        blurView.roundMyCorenrWith(radius: 8)
        deleteButton.roundMyCorenrWith(radius: 8)
        blurButtonView.roundMyCorenrWith(radius: 8)
    }
}
