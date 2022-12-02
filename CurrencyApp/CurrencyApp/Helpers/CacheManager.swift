//
//  CacheManager.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation

class CacheManager {
    
    private static let userDefaults = UserDefaults.standard
    
    static var availableCuurencies: [String: String] {
        get {
            userDefaults.object(forKey: "availableCuurencies") as? [String:String] ?? [:]
        }
        set {
            userDefaults.set(newValue, forKey: "availableCuurencies")
        }
    }
    
    
}
