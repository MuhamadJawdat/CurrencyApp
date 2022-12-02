//
//  ConversionHistory.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation

struct ConversionHistory {
    var dayZeroDate: Date
    var dayZeroConversions: [Conversion]
    var dayMinusOneConversions: [Conversion]
    var dayMinusTwoConversions: [Conversion]
}

struct Conversion {
    let baseCurrencyKey: String
    let targetCurrencyKey: String
    let baseCurrencyValue: Double
    let targetCurrencyValue: Double
}
