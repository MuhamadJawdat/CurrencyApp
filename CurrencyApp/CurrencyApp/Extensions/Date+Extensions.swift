//
//  Date+Extensions.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 04/12/2022.
//

import Foundation

extension Date {
    func daysSince(_ date: Date) -> Double {
        // Use the timeIntervalSince(_:) method to find the time interval between the two dates
        let timeInterval = date.timeIntervalSince(self)
        // Convert the time interval from seconds to days
        let differenceInDays = timeInterval / 86400
        return differenceInDays
    }
}
