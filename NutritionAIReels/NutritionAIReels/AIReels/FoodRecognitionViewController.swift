//
//  ViewController.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapati on 13/04/23.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import AVFoundation
import PassioNutritionAISDK
import ReplayKit

final class FoodRecognitionViewController: UIViewController {

    // MARK: @IBOutlet
    @IBOutlet weak var addFoodButton: UIButton!
    @IBOutlet weak var foodBlurView: UIVisualEffectView!
    @IBOutlet weak var foodView: UIView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    private let passioSDK = PassioNutritionAI.shared
    private let screenRecorder = RPScreenRecorder.shared()
    private let startRecording = "record.circle.fill"
    private let stopRecording = "stop.circle.fill"
    private var settingsView: SettingsView?
    private var foodCardView: FoodCardView?
    private var foodRecord: FoodRecord?
    private var videoLayer: AVCaptureVideoPreviewLayer?
    private var musicPlayer: AVAudioPlayer?
    private var isRecognitionsPaused = false
    private let timeToDisplayBarCodeResults = 2.0
    private var barcodeAttributes: PassioIDAttributes?
    private var lastBarcodeDetection: Date?
    private var isFoodCardViewAnimationStarted = false
    private var captureMode: CaptureMode = .video
    private var foodViewMode: FoodViewMode = .plain
    private var isMusicOn = true
    private var selectedMusic = "Music1.mp3"
    private var sharingTimer: Timer?
    private var timerCreationDate: Date?
    private var shareTimerCount: Int = 0
    private lazy var liveImage = UIImage()
    private lazy var tempVideoPath = URL.getUrlForTempDirectory(pathName: "Food Recognition.mp4")
    private lazy var tempImagePath = URL.getUrlForTempDirectory(pathName: "Food Recognition.jpeg")
    private var foods: [FoodRecord] = [] {
        didSet {
            foods.sort { $0.name.count > $1.name.count }
            foodTableView.isHidden = foods.count > 0 ? false : true
        }
    }

    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        checkCameraPermission()
        configureTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopFoodRecognition()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLayer?.frame = view.bounds
    }
}

// MARK: - Configure UI
extension FoodRecognitionViewController {

    private func configureNavBar() {

        // Configure Navigation bar
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.hidesBackButton = true
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        let image = UIImage(systemName: "gear", withConfiguration: config)
        let rightBarButton = UIBarButtonItem(image: image,
                                             style: .plain,
                                             target: self,
                                             action: #selector(onSettingsTapped))
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarButton
    }

    private func configureTableView() {
        // Configure TableView and other views
        foodTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        foodView.roundMyCorner()
        foodBlurView.roundMyCorner()
        foodTableView.dataSource = self
        foodTableView.register(UINib(nibName: FoodNutritionCell.identifier, bundle: nil),
                               forCellReuseIdentifier: FoodNutritionCell.identifier)
        foodTableView.register(UINib(nibName: FoodCell.identifier, bundle: nil),
                               forCellReuseIdentifier: FoodCell.identifier)
    }

    @objc func onSettingsTapped() {
        // Add Settings View
        let frame = CGRect(x: 0,
                           y: UIScreen.main.bounds.height - 421,
                           width: UIScreen.main.bounds.width,
                           height: 421)

        if settingsView == nil {
            settingsView = SettingsView.fromNib()
            settingsView?.delegate = self
            settingsView?.frame = frame
            settingsView?.captureMode = captureMode
            settingsView?.foodViewMode = foodViewMode
            settingsView?.isMusicOn = isMusicOn
            // Manage views
            foodView.isHidden = true
            foodBlurView.isHidden = true
            showFoodCardView(show: false)
            
            if captureMode == .photo {
                if settingsView == nil {
                    isRecognitionsPaused = true
                } else {
                    isRecognitionsPaused = true
                }
                
            } else {
                isRecognitionsPaused = true
            }

            UIView.animate(withDuration: 0.3, animations: {
                self.settingsView?.alpha = 1
                self.settingsView?.frame = frame
                if let settingsView = self.settingsView {
                    self.view.addSubview(settingsView)
                }
            })
        }
    }

    private func checkCameraPermission() {
        // Check Camera Permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupVideoLayerAndStartRecognition()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupVideoLayerAndStartRecognition()
                    }
                } else {
                    print("The user has not granted to access the camera")
                }
            })
        case .denied:
            print("The user has denied previously to access the camera.")
        case .restricted:
            print("The user can't give camera access due to some restriction.")
        @unknown default:
            print("@unknown default")
        }
    }

    private func setupVideoLayerAndStartRecognition() {
        setupVideoLayer()
        startFoodRecognition()
    }

    private func setupVideoLayer() {
        // Set Video Layer
        guard videoLayer == nil else { return }
        // Use SDK provided preview layer
        if let vLayer = passioSDK.getPreviewLayer() {
            videoLayer = vLayer
            vLayer.frame = view.bounds
            view.layer.insertSublayer(vLayer, at: 0)
        }
    }
}

// MARK: - Start/Stop Food recognition
extension FoodRecognitionViewController {

    private func startFoodRecognition() {

        DispatchQueue.global(qos: .default).async { [self] in
            // Configure Food Detection
            let detectionConfig = FoodDetectionConfiguration(detectVisual: true,
                                                             detectBarcodes: true,
                                                             detectPackagedFood: true)
            // Start Food detection
            passioSDK.startFoodDetection(detectionConfig: detectionConfig,
                                         foodRecognitionDelegate: self) { (ready) in
                if !ready {
                    print("SDK was not configured correctly")
                } else {
                    DispatchQueue.main.async {
                        self.manageViews(isHidden: false)
                    }
                }
            }
        }
    }

    private func stopFoodRecognition() {
        // Stop Food Recognition and remove video layer
        passioSDK.stopFoodDetection()
        isRecognitionsPaused = true
        videoLayer?.removeFromSuperlayer()
        videoLayer = nil
        passioSDK.removeVideoLayer()
    }
}

// MARK: - FoodRecognition Delegate
extension FoodRecognitionViewController: FoodRecognitionDelegate {

    func recognitionResults(candidates: PassioNutritionAISDK.FoodCandidates?,
                            image: UIImage?,
                            nutritionFacts: PassioNutritionAISDK.PassioNutritionFacts?) {

        DispatchQueue.main.async { [self] in
            activityIndicator.stopAnimating()
        }

        // Check Recognition is not Paused and video layer is not nil
        guard !isRecognitionsPaused, videoLayer != nil else { return }

        // Get Live camera image from SDK video layer
        if let image {
            liveImage = image // Used later for capture screenshot
        }

        // Barcode Detection
        if let time = lastBarcodeDetection,
           Date().timeIntervalSince(time) < timeToDisplayBarCodeResults {
            return

        } else if let barcode = candidates?.barcodeCandidates?.first {
            // Barcode detected
            lastBarcodeDetection = Date()
            var barcodeValue = barcode.value
            if barcodeValue.count == 13 && barcodeValue.first == "0" {
                barcodeValue.removeFirst()
            }
            // Fetch Passio Attributes from barcode
            passioSDK.fetchPassioIDAttributesFor(barcode: barcode.value) { (passioIDAttributes) in
                // Show Food View
                if let passioIDAttributes {
                    self.barcodeAttributes = passioIDAttributes
                    DispatchQueue.main.async { [self] in
                        // Create New FoodRecord for Barcode
                        foodRecord = FoodRecord(passioIDAttributes: passioIDAttributes,
                                                replaceVisualPassioID: nil,
                                                replaceVisualName: nil)
                        showFoodView(foodRecord: foodRecord)
                    }
                }
            }
        } else {
            lastBarcodeDetection = nil
            barcodeAttributes = nil
        }

        guard barcodeAttributes == nil else { return }

        // Food Detection
        if let firstCandidate = candidates?.detectedCandidates.first {

            // Create PassioID Attributes from passio ID
            if let pidAtt = passioSDK.lookupPassioIDAttributesFor(passioID: firstCandidate.passioID) {
                // Create FoodRecord from PassioID Attributes
                foodRecord = FoodRecord(passioIDAttributes: pidAtt,
                                        replaceVisualPassioID: pidAtt.passioID,
                                        replaceVisualName: pidAtt.name,
                                        confidence: firstCandidate.confidence)
                // Show Food view
                showFoodView(foodRecord: foodRecord)
            }
        } else {
            // Hide Food view
            hideFoodView()
        }
    }
}

// MARK: - Handel FoodCard View
extension FoodRecognitionViewController {

    private func showFoodView(foodRecord: FoodRecord? = nil) {

        DispatchQueue.main.async { [self] in
            // show Food View base on foodViewMode selection
            if foodViewMode == .plain {
                foodNameLabel.text = foodRecord?.name.capitalizeFirst()
                foodView.isHidden = false
                foodBlurView.isHidden = false
            } else {
                showFoodCardView(show: true, foodRecord: foodRecord)
            }
        }
    }

    private func hideFoodView() {
        DispatchQueue.main.async {
            self.foodView.isHidden = true
            self.foodBlurView.isHidden = true
            self.showFoodCardView(show: false)
        }
    }

    private func showFoodCardView(show: Bool,
                                  foodRecord: FoodRecord? = nil,
                                  isAddFood: Bool = false) {

        if isRecognitionsPaused { return }

        if show, !isRecognitionsPaused, !isFoodCardViewAnimationStarted {
            // Set Frame for FoodCard View
            let foodCardViewframe = CGRect(x: 16,
                                    y: (view.bounds.height/2) + 50,
                                    width: view.bounds.width - 2 * 16,
                                    height: 210)
            // Load and add FoodCardView
            if foodCardView == nil {
                foodCardView = FoodCardView.fromNib()
                foodCardView?.delegate = self
                foodCardView?.roundMyCorenrWith(radius: 8)
                foodCardView?.frame = foodCardViewframe

                if let foodCardView = foodCardView {
                    view.addSubview(foodCardView)
                }
                UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeCubic, animations: {
                    self.foodCardView?.frame = foodCardViewframe
                })
            }

            if foodRecord != foodCardView?.foodRecord {
                foodCardView?.foodRecord = foodRecord
                foodCardView?.frame = foodCardViewframe
                UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .calculationModeCubic, animations: {
                    self.foodCardView?.frame = foodCardViewframe
                })
            }

        } else {

            if !isFoodCardViewAnimationStarted {
                // Animate FoodCard View from center to tableview top while adding food
                if isAddFood {
                    let foodTableFrame = foodTableView.frame
                    UIView.animate(withDuration: 0.8,
                                   delay: 0,
                                   options: .curveEaseIn,
                                   animations: { [self] in
                        isFoodCardViewAnimationStarted = true
                        foodCardView?.frame = CGRect(x: foodTableFrame.origin.x,
                                                     y: foodTableFrame.origin.y + 10,
                                                     width: foodTableFrame.width - 24,
                                                     height: 0)
                        foodCardView?.alpha = 0
                        foodCardView?.layoutIfNeeded()
                    }, completion: { [self] _ in
                        isFoodCardViewAnimationStarted = false
                        foodCardView?.removeFromSuperview()
                        foodCardView = nil
                        if foods.count > 0 {
                            foodTableView.reloadData()
                            isRecognitionsPaused = false
                        }
                    })
                } else { // Animate FoodCardView while hiding
                    UIView.animateKeyframes(withDuration: 0.2,
                                            delay: 0,
                                            options: .calculationModeCubic,
                                            animations: { [self] in
                        isFoodCardViewAnimationStarted = true
                        foodCardView?.alpha = 0
                    }, completion: { [self] _ in
                        isFoodCardViewAnimationStarted = false
                        foodCardView?.removeFromSuperview()
                        foodCardView = nil
                    })
                }
            }
        }
    }
}

// MARK: - FoodCardView Delegate
extension FoodRecognitionViewController: FoodCardViewDelegate {

    // Add FoodRecord to Foods array when tapping on chev up button
    func onAddingFood(foodRecord: FoodRecord?) {
        if let foodRecord {
            foods.append(foodRecord)
        }
        isRecognitionsPaused = false
        showFoodCardView(show: false, isAddFood: true)
    }

    // Pause Recognition when you tap on Food alternative and resume recogntion when you tap on cancel button
    func onAlternativeTapped(pauseRecognition: Bool) {
        isRecognitionsPaused = pauseRecognition
    }
}

// MARK: - UITableViewDataSource
extension FoodRecognitionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foods.count + 1 // For showing Nutrition cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Get calories, carbs, protein, fat from Food Records
        let (calories, carbs, protein, fat) = getNutritionSummaryfor(foodRecords: foods)

        // For 0 IndexPath show Nutrition cell
        if indexPath.row == 0 {
            let cell = tableView.dequeueCell(cellClass: FoodNutritionCell.self, forIndexPath: indexPath)
            cell.calorieLabel.text = "\(Int(calories))"
            cell.carbsLabel.text = "\(Int(carbs))"
            cell.proteinlabel.text = "\(Int(protein))"
            cell.fatLabel.text = "\(Int(fat))"
            return cell

        } else {  // For other IndexPath show Food cell
            let foodRecord = foods[indexPath.row - 1]
            let cell = tableView.dequeueCell(cellClass: FoodCell.self, forIndexPath: indexPath)
            cell.foodNameLabel.text = foodRecord.name.capitalizeFirst()
            cell.deleteButton.tag = indexPath.row - 1
            cell.deleteButton.addTarget(self, action: #selector(onDeleteShareFoodRecord), for: .touchUpInside)
            return cell
        }
    }

    //MARK: Cells Helper
    @objc private func onDeleteShareFoodRecord(_ sender: UIButton) {
        // Delete food and reload table view
        foods.remove(at: sender.tag)
        if foods.count > 0 {
            foodTableView.reloadData()
        }
    }

    private func getNutritionSummaryfor(foodRecords: [FoodRecord]) -> NutritionSummary {
        // Get Calories, Protein, Carbs and Fat from FoodRecords
        var nutritionSum: NutritionSummary = (0, 0, 0, 0)
        foodRecords.forEach {
            nutritionSum.calories += $0.nutritionSummary.calories
            nutritionSum.carbs += $0.nutritionSummary.carbs
            nutritionSum.protein += $0.nutritionSummary.protein
            nutritionSum.fat += $0.nutritionSummary.fat
        }
        return nutritionSum
    }
}

// MARK: - Settings Delegate
extension FoodRecognitionViewController: SettingsDelegate {

    func onCaptureModeValueChanged(mode: CaptureMode) {
        // Perform neccessary view modification when user change Capture mode
        captureMode = mode
        let img = captureMode == .photo ? "camera.circle.fill" : startRecording
        captureButton.setImage(UIImage(systemName: img), for: .normal)
        handleModeChanged()
    }

    func onFoodViewModeValueChanged(mode: FoodViewMode) {
        // Perform neccessary view modification when user change FoodView mode
        foodViewMode = mode
        handleModeChanged()
    }

    func onBackgroundMusicChanged(isOn: Bool) {
        // Turn on/off background music
        isMusicOn = isOn
    }

    func onSelectedMusicChanged(music: String) {
        // Set selected music
        selectedMusic = music
    }

    func onSave() {
        // Remove settings views
        UIView.animate(withDuration: 0.3, animations: {
            self.settingsView?.alpha = 0
        }, completion: { _ in
            self.settingsView?.removeFromSuperview()
            self.settingsView = nil
            self.isRecognitionsPaused = self.captureMode == .video ? true : false
        })
    }

    private func handleModeChanged() {
        // Remove Foods, hide food views and set recognition paused based on selection
        foods = []
        foodTableView.reloadData()
        hideFoodView()
        manageViews(isHidden: false)
    }
}

// MARK: - @IBAction
extension FoodRecognitionViewController {

    @IBAction func onCapture(_ sender: UIButton) {

        switch captureMode {

        case .photo:
            // Check IF food count is not zero
            guard foods.count > 0 else {
                showAlert(alertTitle: "Please scan the food before sharing the photo",
                                  actionHandler: { _ in })
                return
            }
            navigationController?.setNavigationBarHidden(true, animated: false)
            manageViews(isHidden: true)
            // Start Capturing Screenshot
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.shareImage()
            }

        case .video:
            // Start screen recording
            if sharingTimer == nil {
                startScreenRecording()
            } else { // Stop screen recording
                stopScreenRecording()
                cancelShareTimer()
            }
        }
    }

    @IBAction func onAddFood(_ sender: UIButton) {
        // Add FoodRecords to food array when user taps on plain food view's chev up button
        if let foodRecord {
            foods.append(foodRecord)
            foodTableView.reloadData()
        }
    }
}

//MARK: - Handle Sharing Video
extension FoodRecognitionViewController {

    private func startScreenRecording() {

        // Check if screen recording is supported / available
        guard screenRecorder.isAvailable else {
            print("Screen Recording not available")
            return
        }
        navigationController?.setNavigationBarHidden(true, animated: false)
        // Start Recording
        screenRecorder.startRecording(handler: { [weak self] (error) in
            guard let self else { return }
            if let error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
            } else {
                manageShareRecordingView(isRecStarted: true)
                // Create a 60 sec timer for recording video
                let timer = Timer(timeInterval: 1.0,
                                  target: self,
                                  selector: #selector(updateShareTimer),
                                  userInfo: nil,
                                  repeats: true)
                RunLoop.current.add(timer, forMode: .common)
                timer.tolerance = 0.1
                sharingTimer = timer
                timerCreationDate = Date()
                // Only play music when, it's turned on in Settings
                if isMusicOn {
                    playMusic()
                }
            }
        })
    }

    private func stopScreenRecording() {
        // Manage share rec views
        navigationController?.setNavigationBarHidden(false, animated: false)
        musicPlayer?.stop()
        manageShareRecordingView(isRecStarted: false)
        cancelShareTimer()
        // Delete previously saved temp video files if any
        deleteTempFiles(urls: [tempVideoPath])
        // Stop Recording
        screenRecorder.stopRecording(withOutput: tempVideoPath, completionHandler: { [weak self] (error) in
            guard let self else { return }
            DispatchQueue.main.async {
                if let error {
                    print(error.localizedDescription)
                }
                // Show sharing option
                let alert = UIAlertController(title: "Recording Finished",
                                              message: "Would you like to share your recording?",
                                              preferredStyle: .alert)
                // Cancel Action
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .default,
                                                 handler: { _ in
                    self.deleteTempFiles(urls: [self.tempVideoPath])
                    self.deleteFoodsWithReloadData()
                })
                // Share Action
                let shareAction = UIAlertAction(title: "Share",
                                                style: .default,
                                                handler: { _ in
                    // Show Share menu with availabel option
                    self.showActivityViewController(items: [self.tempVideoPath]) { (activityType, _, _, _)  in
                        // Handle activity types action
                        DispatchQueue.main.async {
                            if let activityType {
                                switch activityType {
                                case .saveToCameraRoll:
                                    self.showAlert(alertTitle: "Video Saved")
                                default:
                                    self.showAlert(alertTitle: "Video Shared")
                                }
                            }
                            self.deleteFoodsWithReloadData()
                        }
                    }
                })
                alert.addAction(cancelAction)
                alert.addAction(shareAction)
                self.present(alert, animated: true)
            }
        })
    }

    private func manageShareRecordingView(isRecStarted: Bool) {
        // manage views according to recording
        let imageName = isRecStarted ? stopRecording : startRecording
        captureButton.setImage(UIImage(systemName: imageName), for: .normal)
        foodView.isHidden = true
        foodBlurView.isHidden = true
        showFoodCardView(show: false)
        isRecognitionsPaused = !isRecStarted
    }

    private func playMusic() {
        // Play backgroud music from bundle while recording video
        guard let path = Bundle.main.path(forResource: selectedMusic, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.play()
        } catch {
            print(error)
        }
    }
}

//MARK: - Handle Sharing Photo
extension FoodRecognitionViewController {

    private func shareImage() {
        // Delete Temp videos and images
        deleteTempFiles(urls: [tempImagePath])
        // Create a ImageView from food recognition's image
        let imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.image = liveImage

        // Insert imageView behind current view to capture screenshot
        view.insertSubview(imageView, at: 0)
        let renderer = UIGraphicsImageRenderer(size: view.frame.size)
        let finalImage = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }

        if let jpegImageData = finalImage.jpegData(compressionQuality: 1) {
            // Save imageData into temp directory
            do {
                try jpegImageData.write(to: tempImagePath)
            } catch {
                imageView.removeFromSuperview()
                self.manageShareImageViews()
                print("Error Saving photo in Temp file direcotry:- \(error.localizedDescription)")
            }

            // Show activity controller for performing activity on image
            showActivityViewController(items: [tempImagePath]) { [weak self] (activityType, _, _, _) in
                
                guard let self else { return }
                
                DispatchQueue.main.async {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    
                    if let activityType {
                        switch activityType {
                        case .saveToCameraRoll:
                            self.showAlert(alertTitle: "Photo Saved")
                        default:
                            self.showAlert(alertTitle: "Photo Shared")
                        }
                        self.deleteTempFiles(urls: [self.tempImagePath])
                    }
                    // Remove live camera imageview
                    imageView.removeFromSuperview()
                    self.manageShareImageViews()
                }
            }
        } else {
            imageView.removeFromSuperview()
            manageShareImageViews()
        }
    }
    
    private func manageShareImageViews() {
        // Manage views after capturing photo
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.deleteFoodsWithReloadData()
        self.manageViews(isHidden: false)
    }
}

//MARK: - Helper
extension FoodRecognitionViewController {

    private func manageViews(isHidden: Bool) {

        // Manage views
        foodView.isHidden = true
        foodBlurView.isHidden = true
        showFoodCardView(show: false)

        if captureMode == .photo {
            if settingsView == nil {
                isRecognitionsPaused = isHidden
            } else {
                isRecognitionsPaused = true
            }
            
        } else {
            isRecognitionsPaused = true
        }
        captureButton.isHidden = isHidden
    }

    @objc private func updateShareTimer() {
        // Update timer count, when it reaches 60 sec, stop video recording
        shareTimerCount += 1
        if shareTimerCount > 60 {
            cancelShareTimer()
            stopScreenRecording()
        }
    }

    private func cancelShareTimer() {
        // Invalidate timer
        shareTimerCount = 0
        sharingTimer?.invalidate()
        sharingTimer = nil
    }

    private func deleteTempFiles(urls: [URL]) {
        let fileManager = FileManager.default
        urls.forEach {
            fileManager.deleteRecordLocally(url: $0)
        }
    }

    private func deleteFoodsWithReloadData() {
        DispatchQueue.main.async { [self] in
            foods.removeAll()
            foodTableView.reloadData()
        }
    }
}
