//
//  SecurityManager.swift
//  GPS Uniguard
//
//  Created by Uniguard ID on 22/11/24.
//

import Foundation
import LocalAuthentication

class SecurityManager {
    
    private static let service = "traccar"
    private static let account = "traccar"
    
    static let shared = SecurityManager()
    
    private init() {}
    
    func saveToken(_ token: String) {
        let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
        SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: SecurityManager.service,
            kSecAttrAccount: SecurityManager.account,
            kSecAttrAccessControl: access as Any,
            kSecValueData: Data(token.utf8),
        ] as CFDictionary, nil)
    }
    
    func readToken() -> String? {
        var result: AnyObject?
        SecItemCopyMatching([
            kSecAttrService: SecurityManager.service,
            kSecAttrAccount: SecurityManager.account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary, &result)
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func deleteToken() {
        SecItemDelete([
            kSecAttrService: SecurityManager.service,
            kSecAttrAccount: SecurityManager.account,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary)
    }

}
