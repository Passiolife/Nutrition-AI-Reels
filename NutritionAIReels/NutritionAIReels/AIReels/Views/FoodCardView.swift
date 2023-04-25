//
//  FoodCardView.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 21/04/23.
//

import UIKit
import PassioNutritionAISDK

protocol FoodCardViewDelegate: AnyObject {
    func onAddingFood(foodRecord: FoodRecord?)
    func onAlternativeTapped(pauseRecognition: Bool)
}

final class FoodCardView: UIView {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var cancelAlternativesButton: UIButton!
    @IBOutlet weak var noAlternativeFoundLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var foodUnit: UILabel!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodImgVw: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var alternativeCollectionView: UICollectionView!

    var foodRecord: FoodRecord? {
        didSet {
            configureFoodView()
        }
    }
    weak var delegate: FoodCardViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.roundMyCorenrWith(radius: 8)
        blurView.roundMyCorenrWith(radius: 8)
        addButton.applyBorder(width: 1, color: .white.withAlphaComponent(0.8))
        addButton.roundMyCorner()
        foodImgVw.roundMyCorner()
    }

    func configureFoodView() {
        if let foodRecord {
            foodName.text = foodRecord.name.capitalized
            foodImgVw.loadPassioIconBy(passioID: foodRecord.passioID,
                                       entityType: foodRecord.entityType) { passioIDForImage, image in
                DispatchQueue.main.async {
                    self.foodImgVw.image = image
                }
            }
            foodUnit.text = foodRecord.getServingInfo
            alternativeCollectionView.dataSource = self
            alternativeCollectionView.delegate = self
            cancelAlternativesButton.isHidden = true
            noAlternativeFoundLabel.isHidden = foodRecord.alternativesPassioID == nil ? false : true
            let nib = UINib(nibName: AlternativesMicroCollectionViewCell.identifier, bundle: nil)
            alternativeCollectionView.register(nib, forCellWithReuseIdentifier: AlternativesMicroCollectionViewCell.identifier)
            alternativeCollectionView.reloadData()
        }
    }

    @IBAction func onAddFoodTapped(_ sender: UIButton) {
        delegate?.onAddingFood(foodRecord: foodRecord)
    }
    
    @IBAction func onCancleAlternative(_ sender: UIButton) {
        delegate?.onAlternativeTapped(pauseRecognition: false)
    }
}

// MARK: - UICollectionView methods
extension FoodCardView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        foodRecord?.alternativesPassioID?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(cellClass: AlternativesMicroCollectionViewCell.self,
                                              forIndexPath: indexPath)
        let (name, passioID) = getAlternativeForIndex(index: indexPath.row)
        cell.labelAlternativeName.text = name.capitalized
        cell.passioIDForCell = passioID
        cell.imageAlternative?.loadPassioIconBy(passioID: passioID,
                                                entityType: .item) { passioIDForImage, image in
            if passioIDForImage == cell.passioIDForCell {
                DispatchQueue.main.async {
                    cell.imageAlternative?.image = image
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if var record = getFoodRecordAlternativeForIndex(index: indexPath.row),
           let foodRecord = foodRecord {
            record.uuid = foodRecord.uuid
            self.foodRecord = record
            cancelAlternativesButton.isHidden = false
            delegate?.onAlternativeTapped(pauseRecognition: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let (alternativeTitle, _) = getAlternativeForIndex(index: indexPath.row)
        let sizeForText = alternativeTitle.getFixedTwoLineStringWidth()
        return CGSize(width: 51.0 + sizeForText, height: 42)
    }
    
    func getAlternativeForIndex(index: Int) -> (name: String, passiID: PassioID) {
        
        var name = "No name"
        var passioID = "No passioID "
        if let alt = foodRecord?.alternatives {
            let alternative = alt[index]
            name = alternative.name
            passioID = alternative.passioID
        }
        return (name, passioID)
    }
    
    func getFoodRecordAlternativeForIndex(index: Int) -> FoodRecord? {
        
        if let alt = foodRecord?.alternativesPassioID {
            let pID = alt[index]
            if let pAtt = PassioNutritionAI.shared.lookupPassioIDAttributesFor(passioID: pID) {
                let newFoodRecord = FoodRecord(passioIDAttributes: pAtt,
                                               replaceVisualPassioID: foodRecord?.visualPassioID,
                                               replaceVisualName: foodRecord?.visualName)
                return newFoodRecord
            }
        }
        return nil
    }
}
