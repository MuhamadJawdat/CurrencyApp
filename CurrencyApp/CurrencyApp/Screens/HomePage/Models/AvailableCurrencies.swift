//
//  AvailableCurrencies.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation

struct AvailableCurrencies: Codable {
    var currencies: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case currencies = "symbols"
    }
}
