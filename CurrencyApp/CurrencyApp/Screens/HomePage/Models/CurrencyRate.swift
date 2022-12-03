//
//  CurrencyRate.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 03/12/2022.
//

import Foundation

struct CurrencyRate: Codable {
    let baseCurrency: String?
    var rates: [String:Double]?
    
    enum CodingKeys: String, CodingKey {
        case baseCurrency = "base"
        case rates
    }
}
