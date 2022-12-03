//
//  Double+Extensions.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 03/12/2022.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
