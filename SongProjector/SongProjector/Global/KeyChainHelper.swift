//
//  KeyChainHelper.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Security
import Foundation

class KeychainService {
    
    static func updateItem(_ password: String, serviceKey: String) {
        guard let dataFromString = password.data(using: .utf8) else { return }
        
        let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                               kSecAttrService: serviceKey,
                                               kSecValueData: dataFromString]
        SecItemDelete(keychainQuery as CFDictionary)
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    static func removeItem(serviceKey: String) {
        
        let keychainQuery: [CFString : Any] = [kSecClass: kSecClassGenericPassword,
                                               kSecAttrService: serviceKey]
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    static func loadItem(serviceKey: String) -> String? {
        let keychainQuery: [CFString : Any] = [kSecClass : kSecClassGenericPassword,
                                               kSecAttrService : serviceKey,
                                               kSecReturnData: kCFBooleanTrue as Any,
                                               kSecMatchLimitOne: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        guard let retrievedData = dataTypeRef as? Data else { return nil }
        
        return String(data: retrievedData, encoding: .utf8)
    }
    
}
