//
//  SharedFoodNutritionCell.swift
//  NaiyaApp
//
//  Created by Nikunj Prajapati on 23/02/23.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import UIKit

final class FoodNutritionCell: UITableViewCell {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var proteinlabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.roundMyCorner()
        let borderColor = UIColor(red: 0.937, green: 0.941, blue: 0.965, alpha: 0.65)
        containerView.applyBorder(width: 1, color: borderColor)
        blurView.roundMyCorner()
    }
}
