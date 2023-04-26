//
//  EntryViewController.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapti on 26/04/23.
//

import UIKit
import PassioNutritionAISDK

final class EntryViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sdkStatusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        startButton.roundMyCorenrWith(radius: 20)
        configureSDK()
    }

    private func configureSDK() {

        let passioSDK = PassioNutritionAI.shared
        // Configure SDK with key
        #error("Use the API key you received from us or request a key from support@passiolife.com. Delete this line before building.")
        let key = "" // Add your key here.
        let passioConfig = PassioConfiguration(key: key)
        passioSDK.statusDelegate = self
        passioSDK.configure(passioConfiguration: passioConfig) { (status) in
            print("Mode = \(status.mode)\nMissingfiles = \(String(describing: status.missingFiles))")
        }
    }

    @IBAction func onStartTapped(_ sender: UIButton) {

        // Navigate to FoodRecognition VC
        guard let foodRecognitionVC = UIStoryboard.main.getViewController(controller: FoodRecognitionViewController.self) else {
            return
        }
        navigationController?.pushViewController(foodRecognitionVC, animated: true)
    }
}

// MARK: - PassioStatus Delegate
extension EntryViewController: PassioStatusDelegate {

    func passioStatusChanged(status: PassioStatus) {

        guard PassioNutritionAI.shared.status.mode == .isReadyForDetection else { return }
        // SDK is ready for Food detection
        DispatchQueue.main.async { [self] in
            sdkStatusLabel.isHidden = true
            activityIndicator.stopAnimating()
            startButton.isHidden = false
        }
    }

    func passioProcessing(filesLeft: Int) {
        DispatchQueue.main.async {
            self.sdkStatusLabel.text = "Files left to Process \(filesLeft)"
        }
    }

    func completedDownloadingAllFiles(filesLocalURLs: [FileLocalURL]) {
        DispatchQueue.main.async {
            self.sdkStatusLabel.text = "Completed downloading all files"
        }
    }

    func completedDownloadingFile(fileLocalURL: FileLocalURL, filesLeft: Int) {
        DispatchQueue.main.async {
            self.sdkStatusLabel.text = "Files left to download \(filesLeft)"
        }
    }

    func downloadingError(message: String) {
        print("Download Error-= \(message)")
        DispatchQueue.main.async {
            self.sdkStatusLabel.text = "\(message)"
            self.activityIndicator.stopAnimating()
        }
    }
}
