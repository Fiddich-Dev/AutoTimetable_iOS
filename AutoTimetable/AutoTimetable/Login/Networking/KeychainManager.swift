//
//  KeychainManager.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation
import SwiftKeychainWrapper

class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    func save(_ value: String, forKey key: String) {
        KeychainWrapper.standard.set(value, forKey: key)
    }

    func read(forKey key: String) -> String? {
        return KeychainWrapper.standard.string(forKey: key)
    }

    func delete(forKey key: String) {
        KeychainWrapper.standard.removeObject(forKey: key)
    }
}
