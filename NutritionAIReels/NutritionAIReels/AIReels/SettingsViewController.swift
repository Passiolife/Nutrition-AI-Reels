//
//  SettingsViewController.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 25/04/23.
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
}

final class SettingsViewController: UIViewController {

    @IBOutlet weak var captureModeSegment: UISegmentedControl!
    @IBOutlet weak var foodViewModeSegment: UISegmentedControl!
    @IBOutlet weak var backgroundMusicSegment: UISegmentedControl!
    @IBOutlet weak var chooseMusicButton: UIButton!
    @IBOutlet weak var chooseMusicStackView: UIStackView!
    @IBOutlet weak var backgroundMusicStackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!

    var captureMode: CaptureMode = .video
    var foodViewMode: FoodViewMode = .plain
    var isMusicOn = true

    weak var delegate: SettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        chooseMusicButton.applyBorder(width: 1, color: .systemOrange)
        chooseMusicButton.roundMyCorenrWith(radius: 8)
        saveButton.applyBorder(width: 1, color: .systemOrange)
        saveButton.roundMyCorenrWith(radius: 8)

        // Read user choice
        captureModeSegment.selectedSegmentIndex = captureMode == .photo ? 0 : 1
        foodViewModeSegment.selectedSegmentIndex = foodViewMode == .plain ? 0 : 1
        backgroundMusicSegment.selectedSegmentIndex = isMusicOn == true ? 0 : 1
        backgroundMusicStackView.isHidden = captureMode == .photo ? true : false
        chooseMusicStackView.isHidden = backgroundMusicStackView.isHidden ? true : isMusicOn ? false : true

        // Show music menu on button tap
        showMusicMenu()
    }
}

// MARK: - @IBAction
extension SettingsViewController {

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
        dismiss(animated: true)
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
}
