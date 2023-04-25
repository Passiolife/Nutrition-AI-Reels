//
//  UIViewControllerExtension.swift
//  Passio App Module
//
//  Created by Nikunj Prajapati on 27/12/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlert(alertTitle: String, actionHandler: ((UIAlertAction) -> Void)? = nil) {

        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: actionHandler))
        present(alert, animated: true, completion: nil)
    }

    func showActivityViewController(items: [Any],
                                    completionHandler: ((UIActivity.ActivityType?,
                                                         Bool,
                                                         [Any]?,
                                                         Error?) -> Void)? = nil) {
        let activityController = UIActivityViewController(activityItems: items,
                                                          applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = view
        activityController.popoverPresentationController?.sourceRect = view.frame
        activityController.completionWithItemsHandler = completionHandler
        present(activityController, animated: true, completion: nil)
    }
}
