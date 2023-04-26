//
//  UIStoryboard+Extension.swift
//  NutritionAIReels
//
//  Created by Nikunj Prajapti on 26/04/23.
//

import UIKit

enum StoryboardName: String {
    case main = "Main"
}

extension UIStoryboard {

    static var main: UIStoryboard {
        return UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
    }

    func getViewController<T: UIViewController>(controller: T.Type) -> T? {
        return instantiateViewController(withIdentifier: String(describing: controller)) as? T
    }
}
