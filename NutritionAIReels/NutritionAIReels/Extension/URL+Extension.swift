//
//  URL+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 26/12/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import Foundation

extension URL {

    static func getUrlForTempDirectory(pathName: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent(pathName)
    }
}
