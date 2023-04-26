//
//  SettingsView.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 26/04/23.
//

import UIKit

enum CaptureMode {
    case photo, video
}
enum FoodViewMode {
    case plain, detail
}

protocol SettingsDelegate: AnyObject {
    func onCaptureModeValueChanged(mode: CaptureMode)
    func onFoodViewModeValueChanged(mode: FoodViewMode)
    func onBackgroundMusicChanged(isOn: Bool)
    func onSelectedMusicChanged(music: String)
    func onSave()
}

final class SettingsView: UIView {

    @IBOutlet weak var captureModeSegment: UISegmentedControl!
    @IBOutlet weak var foodViewModeSegment: UISegmentedControl!
    @IBOutlet weak var backgroundMusicSegment: UISegmentedControl!
    @IBOutlet weak var chooseMusicButton: UIButton!
    @IBOutlet weak var chooseMusicStackView: UIStackView!
    @IBOutlet weak var backgroundMusicStackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!

    var captureMode: CaptureMode = .video {
        didSet {
            captureModeSegment.selectedSegmentIndex = captureMode == .photo ? 0 : 1
        }
    }
    var foodViewMode: FoodViewMode = .plain  {
        didSet {
            foodViewModeSegment.selectedSegmentIndex = foodViewMode == .plain ? 0 : 1
        }
    }
    var isMusicOn = true  {
        didSet {
            backgroundMusicSegment.selectedSegmentIndex = isMusicOn == true ? 0 : 1
            backgroundMusicStackView.isHidden = captureMode == .photo ? true : false
            chooseMusicStackView.isHidden = backgroundMusicStackView.isHidden ? true : isMusicOn ? false : true
        }
    }

    weak var delegate: SettingsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.alpha = 0
        roundMyCornerWith(radius: 40, upper: true, down: false)
        chooseMusicButton.applyBorder(width: 1, color: .white)
        chooseMusicButton.roundMyCorenrWith(radius: 8)
        saveButton.applyBorder(width: 1, color: .white)
        saveButton.roundMyCorenrWith(radius: 8)

        

        // Show music menu on button tap
        showMusicMenu()
        addSwipeDownGesture()
    }

    private func addSwipeDownGesture() {
        // Add Swipe Down gesture to remove view
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeDown))
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
    }
}

// MARK: - @IBAction
extension SettingsView {

    @IBAction func onCaptureModeChanged(_ sender: UISegmentedControl) {
        let mode: CaptureMode = sender.selectedSegmentIndex == 0 ? .photo : .video
        backgroundMusicStackView.isHidden = sender.selectedSegmentIndex == 0 ? true : false
        chooseMusicStackView.isHidden = backgroundMusicStackView.isHidden
        delegate?.onCaptureModeValueChanged(mode: mode)
    }

    @IBAction func onFoodViewModeChanged(_ sender: UISegmentedControl) {
        let mode: FoodViewMode = sender.selectedSegmentIndex == 0 ? .plain : .detail
        delegate?.onFoodViewModeValueChanged(mode: mode)
    }

    @IBAction func onBackgroundMusicModeChanged(_ sender: UISegmentedControl) {
        let isOn = sender.selectedSegmentIndex == 0 ? true : false
        chooseMusicStackView.isHidden = !isOn
        delegate?.onBackgroundMusicChanged(isOn: isOn)
    }

    @IBAction func onSaveTapped(_ sender: UIButton) {
        delegate?.onSave()
    }

    private func showMusicMenu() {

        let music1Action = UIAction(title: "Music 1", handler: { [weak self] _ in
            self?.delegate?.onSelectedMusicChanged(music: "Music1.mp3")
        })

        let music2Action = UIAction(title: "Music 2", handler: { [weak self] _ in
            self?.delegate?.onSelectedMusicChanged(music: "Music2.mp3")
        })

        let music3Action = UIAction(title: "Music 3", handler: { [weak self] _ in
            self?.delegate?.onSelectedMusicChanged(music: "Music3.mp3")
        })

        chooseMusicButton.showsMenuAsPrimaryAction = true
        chooseMusicButton.menu = UIMenu(title: "Music", children: [music1Action, music2Action, music3Action])
    }

    @objc private func onSwipeDown() {
        delegate?.onSave()
    }
}
