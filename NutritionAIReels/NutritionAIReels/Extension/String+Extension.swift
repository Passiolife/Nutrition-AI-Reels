//
//  String+Extension.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 13/04/23.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

extension String {
    
    func capitalizeFirst() -> String {
        prefix(1).capitalized + dropFirst()
    }

    func getFixedTwoLineStringWidth() -> Double {
        let label = UILabel()
        label.numberOfLines = 2
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        var sizeForText = Double()
        if words.count == 1 {
            label.text = self
            label.sizeToFit()
            sizeForText = Double(label.frame.width)
            if words.first!.count < 6 {
                sizeForText += 10
            }
        } else if words.count == 2 {
            let maxWord = words.max {$1.count > $0.count}
            label.text = maxWord
            label.sizeToFit()
            sizeForText = Double(label.frame.width)*1.2
            if maxWord!.count < 6 {
                sizeForText += 10
            }
        } else if words.count == 3 {
            let maxCount = max(words[0].count, words[2].count)
            if maxCount == (words[0].count) {
                let maxCount = max(words[0].count, (words[1].count + 1 + words[2].count))
                if maxCount == words[0].count {
                    label.text = words[0]
                } else {
                    label.text = words[1] + " " + words[2]
                }
            } else {
                let maxCount = max(words[0].count + 1 + words[1].count, words[2].count)
                if maxCount == words[2].count {
                    label.text = words[2]
                } else {
                    label.text = words[0] + " " + words[1]
                }
            }
            label.sizeToFit()
            sizeForText = Double(label.frame.width)
        } else {
            label.text = self
            label.sizeToFit()
            sizeForText = Double(label.frame.width)/2
        }
        return sizeForText
    }
}
