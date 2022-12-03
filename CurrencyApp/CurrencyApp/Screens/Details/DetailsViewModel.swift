//
//  DetailsViewModel.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 03/12/2022.
//

import Foundation
import RxSwift

class DetailsViewModel {
    
    var recentConversions = PublishSubject<[Conversion]>()
    var otherConversions = PublishSubject<[Conversion]>()
    
    func setupData() {
        recentConversions.onNext(CacheManager.conversionHistory.allHistory)
        recentConversions.onCompleted()
    }
    
    func generateOtherCurrencyConversions(baseCurrency: String?, previousTargetCurrency: String?, baseAmount: Double?) {
        guard let baseCurrency,
              let previousTargetCurrency,
              let baseAmount else {return}
        var conversions = [Conversion]()
        CacheManager.storedRates.forEach {
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
}
