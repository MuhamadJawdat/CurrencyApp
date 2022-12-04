//
//  ConversionHistory.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation
import RxDataSources

struct Conversion: Codable, Equatable {
    let date: Date?
    let baseCurrency: String
    let targetCurrency: String
    let baseAmount: Double
    let targetAmount: Double
    
    init(date: Date? = nil, baseCurrency: String, targetCurrency: String, baseAmount: Double, targetAmount: Double) {
        self.date = date
        self.baseCurrency = baseCurrency
        self.targetCurrency = targetCurrency
        self.baseAmount = baseAmount
        self.targetAmount = targetAmount
    }
}

struct ConversionHistoryDay: SectionModelType {
    typealias Item = Conversion
    
    let day: String
    var conversions: [Conversion]
    
    init(day: String, conversions: [Conversion]) {
        self.day = day
        self.conversions = conversions
    }
    
    // required for SectionModelType
    init(original: ConversionHistoryDay, items: [Conversion]) {
        self = original
    }
    
    var header: String {
        day
    }
    var items: [Conversion] {
        conversions
    }
}
