//
//  CacheManager.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation

class CacheManager {
    
    private static let userDefaults = UserDefaults.standard
    private static let conversionsStorageDaysLimit: Double = 3
    
    static var availableCurrencies: [String: String] {
        get {
            userDefaults.object(forKey: "availableCuurencies") as? [String:String] ?? [:]
        }
        set {
            userDefaults.set(newValue, forKey: "availableCuurencies")
        }
    }
    
    static var storedRates: [CurrencyRate] {
        get {
            if let storedRates = userDefaults.object(forKey: "storedRates") as? Data {
                let decoder = JSONDecoder()
                if let data = try? decoder.decode([CurrencyRate].self, from: storedRates) {
                    return data
                } else {
                    return []
                }
            }
            return []
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                userDefaults.set(encoded, forKey: "storedRates")
            }
        }
    }
    
    static var conversionHistory: [Conversion] {
        get {
            if let storedRates = userDefaults.object(forKey: "conversionHistory") as? Data {
                let decoder = JSONDecoder()
                if let data = try? decoder.decode([Conversion].self, from: storedRates) {
                    return data
                } else {
                    return []
                }
            }
            return []
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                userDefaults.set(encoded, forKey: "conversionHistory")
            }
        }
    }
    
    static func filterOldConversions() {
        conversionHistory = conversionHistory.compactMap {
            if let conversionDate = $0.date,
                conversionDate.daysSince(Date()) < conversionsStorageDaysLimit {
                return $0
            } else {
                return nil
            }
        }
    }
    
    static func addConversionToHistory(baseCurrency: String? , baseAmount: Double?, targetCurrency: String?, targetAmount: Double?) {
        CacheManager.filterOldConversions()
        guard let baseCurrency,
              let baseAmount,
              let targetCurrency,
              let targetAmount else {return}
        let conversion = Conversion(date: Date(),
                                    baseCurrency: baseCurrency,
                                    targetCurrency: targetCurrency,
                                    baseAmount: baseAmount,
                                    targetAmount: targetAmount)
        var updatedConversionHistory = CacheManager.conversionHistory
        if updatedConversionHistory.first(where: {$0 == conversion}) == nil,
           baseCurrency != targetCurrency {
            updatedConversionHistory.append(conversion)
        }
        conversionHistory = updatedConversionHistory
    }
}
