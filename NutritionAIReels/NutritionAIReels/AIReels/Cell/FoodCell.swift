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

        foodView.roundMyCorner()
        let borderColor = UIColor(red: 0.937, green: 0.941, blue: 0.965, alpha: 0.65)
        foodView.applyBorder(width: 1, color: borderColor)
        blurView.roundMyCorner()
        deleteButton.roundMyCorner()
        let borderColor2 = UIColor(red: 1, green: 1, blue: 1, alpha: 0.10)
        deleteButton.applyBorder(width: 1, color: borderColor2)
        blurButtonView.roundMyCorner()
    }
}
