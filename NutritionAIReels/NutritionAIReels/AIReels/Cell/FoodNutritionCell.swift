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

        containerView.roundMyCorenrWith(radius: 8)
        blurView.roundMyCorenrWith(radius: 8)
    }
}
