//
//  DetailsViewModel.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 03/12/2022.
//

import Foundation
import RxSwift

final class DetailsViewModel {
    
    lazy var storedRates: [CurrencyRate] = {
        CacheManager.storedRates
    }()
    
    lazy var conversionHistory: [Conversion] = {
        CacheManager.conversionHistory
    }()
    
    let otherCurrenciesLimit = 10
    
    var otherConversions = PublishSubject<[Conversion]>()
    var recentConversions = PublishSubject<[ConversionHistoryDay]>()
    
    func setupData() {
        fetchRecentConversions()
    }
    
    func generateOtherCurrencyConversions(baseCurrency: String?, previousTargetCurrency: String?, baseAmount: Double?) {
        guard let baseCurrency,
              let previousTargetCurrency,
              let baseAmount else {return}
        var conversions = [Conversion]()
        storedRates.forEach {
            guard conversions.count < otherCurrenciesLimit else {return}
            guard let targetCurrency = $0.baseCurrency,
                  targetCurrency != baseCurrency,
                  targetCurrency != previousTargetCurrency,
                  let rate = $0.rates?[baseCurrency] else {return}
            conversions.append(Conversion(baseCurrency: baseCurrency,
                                          targetCurrency: targetCurrency,
                                          baseAmount: baseAmount,
                                          targetAmount: (baseAmount / rate).roundToDecimal(4)))
        }
        otherConversions.onNext(conversions)
    }
    
    func fetchRecentConversions() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.doesRelativeDateFormatting = true
        var fetchedConversationsByDays = [ConversionHistoryDay]()
        
        conversionHistory.forEach { conversion in
            // validating Day is available
            guard let conversionDate = conversion.date else {return}
            // Formatte Date to a day string
            let dateAsDayString = dateFormatter.string(from: conversionDate)
            // getting index of fetched Conversion of day matching day in the current conversion from conversion history
            guard let index = fetchedConversationsByDays.firstIndex (where: { fetchedConversion in
                fetchedConversion.day == dateAsDayString
            }) else {
                // otherwise there is no fetched conversion for the day of this conversion, so we create the first for this day, and add it at first, so that it always shows at the top in UI without the need to reverse it later
                fetchedConversationsByDays.insert(ConversionHistoryDay(day: dateAsDayString,
                                                                       conversions: [conversion]),
                                                  at: 0)
                return
            }
            // in case this day is already available, then we append the conversion in it
            fetchedConversationsByDays[index].conversions.append(conversion)
        }
        
        recentConversions.onNext(fetchedConversationsByDays)
        recentConversions.onCompleted()
    }
}
