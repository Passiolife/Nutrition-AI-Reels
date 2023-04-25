//
//  FileManager+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 27/12/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import Foundation

extension FileManager {

    @discardableResult
    func deleteRecordLocally(url: URL) -> Bool {
        if fileExists(atPath: url.path) {
            do {
                try removeItem(atPath: url.path)
                return true
            } catch {
                print("No record was found")
                return false
            }
        }
        return false
    }
}
