//
//  ConversionHistory.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation

struct ConversionHistory: Codable {
    var dayZeroDate: Date
    var dayZeroConversions: [Conversion]
    var dayMinusOneConversions: [Conversion]
    var dayMinusTwoConversions: [Conversion]
    
    var allHistory: [Conversion] {
        dayZeroConversions + dayMinusOneConversions + dayMinusTwoConversions
    }
    
    init() {
        dayZeroDate = Date()
        dayZeroConversions = []
        dayMinusOneConversions = []
        dayMinusTwoConversions = []
    }
}

struct Conversion: Codable, Equatable {
    let baseCurrency: String
    let targetCurrency: String
    let baseAmount: Double
    let targetAmount: Double
}
