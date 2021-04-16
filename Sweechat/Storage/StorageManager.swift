//
//  StorageManager.swift
//  Sweechat
//
//  Created by Agnes Natasya on 11/4/21.
//

import Foundation

struct StorageManager {
    static func getFileURL(from name: String, with fileExtension: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(name).appendingPathExtension(fileExtension)
    }
}
