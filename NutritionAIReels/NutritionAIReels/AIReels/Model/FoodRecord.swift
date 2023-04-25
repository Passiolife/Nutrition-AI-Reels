//
//  FoodRecord.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 21/04/23.
//

import UIKit
import PassioNutritionAISDK

typealias NutritionSummary = (calories: Double, carbs: Double, protein: Double, fat: Double)

struct FoodRecord: Codable, Equatable {

    let passioID: PassioID
    var name: String
    var uuid: String
    var visualPassioID: PassioID?
    var visualName: String?
    var nutritionalPassioID: PassioID?
    var scannedUnitName = "scanned amount"
    var servingSizes: [PassioServingSize]
    var servingUnits: [PassioServingUnit]
    var entityType: PassioIDEntityType

    private(set) var selectedUnit: String
    private(set) var selectedQuantity: Double
    private(set) var ingredients: [PassioFoodItemData]
    private(set) var parents: [PassioAlternative]?
    private(set) var siblings: [PassioAlternative]?
    private(set) var children: [PassioAlternative]?

    var alternativesPassioID: [PassioID]? { alternatives?.compactMap { $0.passioID } }
    var alternatives: [PassioAlternative]? {
        let alt = (parents ?? []) + (children ?? []) + (siblings ?? [])
        return alt.isEmpty ? nil : alt
    }
    var totalCalories: Double {
        ingredients.map {$0.totalCalories?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 0)
    }
    var totalCarbs: Double {
        ingredients.map {$0.totalCarbs?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }
    var totalProteins: Double {
        ingredients.map {$0.totalProteins?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }
    var totalFat: Double {
        ingredients.map {$0.totalFat?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }
    var nutritionSummary: NutritionSummary {
        (calories: totalCalories, carbs: totalCarbs, protein: totalProteins, fat: totalFat)
    }
    var computedWeight: Measurement<UnitMass> {
        guard let weight2UnitRatio = (servingUnits.filter {$0.unitName == selectedUnit}).first?.weight.value else {
            return Measurement<UnitMass>(value: 0, unit: .grams)
        }
        return Measurement<UnitMass>(value: weight2UnitRatio * selectedQuantity, unit: .grams)
    }

    // MARK: Init
    init(passioIDAttributes: PassioIDAttributes,
         replaceVisualPassioID: PassioID?,
         replaceVisualName: String?,
         confidence: Double? = nil,
         scannedWeight: Double? = nil) {
        
        passioID = passioIDAttributes.passioID
        if let vPassioID = replaceVisualPassioID {
            visualPassioID = vPassioID
        } else {
            visualPassioID = passioIDAttributes.passioID
        }
        if let vName = replaceVisualName {
            visualName = vName
        } else {
            visualName = passioIDAttributes.name
        }
        name = passioIDAttributes.name
        
        if passioIDAttributes.entityType == .recipe,
           let recipe = passioIDAttributes.recipe { // Recipe
            ingredients = recipe.foodItems
            selectedUnit = recipe.selectedUnit
            selectedQuantity = recipe.selectedQuantity
            servingSizes = recipe.servingSizes
            servingUnits = recipe.servingUnits
            nutritionalPassioID = recipe.passioID
        } else { // Not a Recipe
            if let foodItemData = passioIDAttributes.passioFoodItemData {
                nutritionalPassioID = foodItemData.passioID
                ingredients = [foodItemData]
                selectedUnit = foodItemData.selectedUnit
                selectedQuantity = foodItemData.selectedQuantity
                servingSizes = foodItemData.servingSizes
                servingUnits = foodItemData.servingUnits
            } else {
                nutritionalPassioID = passioID
                ingredients = []
                selectedUnit = "gram"
                selectedQuantity = 0.0
                servingSizes = []
                servingUnits = []
            }
        }
        parents = passioIDAttributes.parents
        siblings = passioIDAttributes.siblings
        children = passioIDAttributes.children
        entityType = passioIDAttributes.entityType
        uuid = UUID().uuidString
        if let scannedWeight = scannedWeight {
            addScannedAmount(scannedWeight: scannedWeight)
        } else {
            _ = setFoodRecordServing(unit: selectedUnit, quantity: selectedQuantity)
        }
    }

    mutating public func addScannedAmount(scannedWeight: Double) {

        guard scannedWeight > 1, scannedWeight < 50000 else { return }
        let scannedServingUnit = PassioServingUnit(unitName: scannedUnitName,
                                                   weight: Measurement<UnitMass>(value: scannedWeight, unit: .grams))
        let scannedServingSize = PassioServingSize(quantity: 1, unitName: scannedUnitName)
        servingUnits.insert(scannedServingUnit, at: 0)
        servingSizes.insert(scannedServingSize, at: 0)
        _ = setFoodRecordServing(unit: scannedUnitName, quantity: 1)
    }

    mutating public func setFoodRecordServing(unit: String, quantity: Double) -> Bool {

        guard (servingUnits.filter {$0.unitName == unit}).first?.weight != nil else {
            return false
        }
        selectedUnit = unit
        selectedQuantity = quantity
        computeQuantityForIngredients()
        return true
    }

    mutating private func computeQuantityForIngredients() {

        let totalWeight = ingredients.map {$0.computedWeight.value}.reduce(0, +)
        let ratioMultiply = computedWeight.value/totalWeight
        var newIngredient = [PassioFoodItemData]()
        ingredients.forEach {
            var tempFood = $0
            _ = tempFood.setFoodItemDataServingSize(unit: tempFood.selectedUnit,
                                                    quantity: tempFood.selectedQuantity * ratioMultiply)
            newIngredient.append(tempFood)
        }
        ingredients = newIngredient
    }
}

extension FoodRecord {
    
    var getServingInfo: String {
        let quantity = self.selectedQuantity
        let title = self.selectedUnit.capitalized
        let weight = String(self.computedWeight.value.roundDigits(afterDecimal: 2))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
        String(quantity.roundDigits(afterDecimal: 2))
        let weightText = title == "g" ? "" : "(" + weight + " " + "g" + ") "
        return textAmount + " " + title + " " + weightText
    }
}
