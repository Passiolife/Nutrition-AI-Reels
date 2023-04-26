//
//  AlternativesCollectionViewCell.swift
//  PassioPassport
//
//  Created by zvika on 2/2/19.
//  Copyright © 2022 Passiolife Inc. All rights reserved.
//

import UIKit
import PassioNutritionAISDK

final class AlternativesMicroCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageAlternative: UIImageView!
    @IBOutlet weak var labelAlternativeName: UILabel!

    var passioIDForCell: PassioID?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageAlternative?.roundMyCorner()
        roundMyCorner()
        applyBorder(width: 1, color: .white.withAlphaComponent(0.2))
    }
}
