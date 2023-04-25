//
//  Double+Extension.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 21/04/23.
//

import Foundation

extension Double {

    func roundDigits(afterDecimal: Int) -> Double {
        let multiplier = pow(10, Double(afterDecimal))
        return (self * multiplier).rounded()/multiplier
    }
}
