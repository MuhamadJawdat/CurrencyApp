//
//  HomePageViewModel.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation
import RxSwift

final class HomePageViewModel: FixerAPINetworkable {
    
    var availableCurrencies = PublishSubject<[String]>()
    var currencyRates = PublishSubject<[CurrencyRate]>()
    
    var baseAmount = PublishSubject<Double>()
    var convertedAmount = PublishSubject<Double>()
    
    var baseCurrency = PublishSubject<String>()
    var targetConversionCurrency = PublishSubject<String>()
    
    var isCurrenciesCacheAvailable: Bool {
        !CacheManager.availableCurrencies.isEmpty
    }
    
    var availableCurrenciesSortedKeys: [String] {
        CacheManager.availableCurrencies.keys.sorted(by: {$0 < $1})
    }
    
    let disposeBag = DisposeBag()
    
    func flipConversionSides(baseCurrency: String, targetCurrency: String, convertedAmount: Double?, baseAmount: Double?) {
        updateBaseCurrency(data: targetCurrency)
        updateTargetConversionCurrency(data: baseCurrency)
        if let convertedAmount = convertedAmount {
            updateBaseAmount(data: convertedAmount)
        } else if let baseAmount = baseAmount {
            updateConvertedAmount(data: baseAmount)
            convertValue(baseCurrency: targetCurrency,
                                        targetConversionCurrency: baseCurrency,
                                        convertedAmount: baseAmount)
        }
    }
    
    func setupViewModel() {
        initializeConversionSubscription()
        
        updateBaseCurrency(data: availableCurrenciesSortedKeys.first)
        updateTargetConversionCurrency(data: availableCurrenciesSortedKeys.first)
        updateBaseAmount(data: 1.0)
        updateConvertedAmount(data: 1.0)
    }
    
    func initializeConversionSubscription() {
        let conversionInput = Observable.combineLatest(baseCurrency, targetConversionCurrency, baseAmount)
        _ = conversionInput.subscribe(onNext: { [weak self] (baseCurrency,targetConversionCurrency,baseAmount) in
            guard let self = self else {return}
            guard (CacheManager.storedRates.first {$0.baseCurrency == baseCurrency}) != nil else {
                self.currencyRates.subscribe(onNext: { [weak self] _ in
                    self?.convertValue(baseCurrency: baseCurrency, targetConversionCurrency: targetConversionCurrency, baseAmount: baseAmount)
                })
                .disposed(by: self.disposeBag)
                self.fetchRatesForCurrency(currency:baseCurrency)
                return
            }
            self.convertValue(baseCurrency: baseCurrency, targetConversionCurrency: targetConversionCurrency, baseAmount: baseAmount)
        }).disposed(by: disposeBag)
    }
    
    func fetchAvailableCurrencies() {
        guard !isCurrenciesCacheAvailable else {
            updateAvailableCurrencies(data: CacheManager.availableCurrencies)
            return
        }
        getAvailableCurrencies { [weak self] currencies in
            self?.updateAvailableCurrencies(data: currencies)
            CacheManager.availableCurrencies = currencies
        }
    }
    
    func fetchRatesForCurrency(currency: String) {
        
        var storedRates = CacheManager.storedRates
        
        let isCurrencyRatesAvailable = (storedRates.first(where: {$0.baseCurrency == currency}) != nil)
        
        guard !isCurrencyRatesAvailable else {
            updateAvailableCurrencyRates(data: storedRates)
            return
        }
        
        getCurrencyRates(GetCurrencyRatesRequest(baseCurrency: currency, targetCurrencies: Array(CacheManager.availableCurrencies.keys))) { [weak self] currencyRate in
            guard let self = self,
                  let rates = currencyRate.rates else {
                return
            }

            if isCurrencyRatesAvailable {
                storedRates = storedRates.map {
                    if $0.baseCurrency == currency {
                        var storedRate = $0
                        storedRate.rates = rates
                        return $0
                    } else {
                        return $0
                    }
                }
                CacheManager.storedRates = storedRates
                self.updateAvailableCurrencyRates(data: storedRates)
            } else {
                storedRates.append(currencyRate)
                CacheManager.storedRates = storedRates
                self.updateAvailableCurrencyRates(data: storedRates)
            }
        }
    }
    
    func convertValue(baseCurrency: String, targetConversionCurrency: String, baseAmount: Double) {
        guard let rate = CacheManager.storedRates.first(where: {$0.baseCurrency == baseCurrency})?.rates?.first(where: {$0.key == targetConversionCurrency})?.value else {
            print("Rate retrievable error")
            return
        }
        let convertedAmountResult = (baseAmount * rate).roundToDecimal(4)
        updateConvertedAmount(data: convertedAmountResult)
        CacheManager.addConversionToHistory(baseCurrency: baseCurrency,
                               baseAmount: baseAmount,
                               targetCurrency: targetConversionCurrency,
                               targetAmount: convertedAmountResult)
    }
    
    func convertValue(baseCurrency: String, targetConversionCurrency: String, convertedAmount: Double) {
        guard let rate = CacheManager.storedRates.first(where: {$0.baseCurrency == baseCurrency})?.rates?.first(where: {$0.key == targetConversionCurrency})?.value else {
            print("Rate retrievable error")
            return
        }
        let baseAmountResult = (convertedAmount / rate).roundToDecimal(4)
        updateBaseAmount(data: baseAmountResult)
        CacheManager.addConversionToHistory(baseCurrency: baseCurrency,
                               baseAmount: baseAmountResult,
                               targetCurrency: targetConversionCurrency,
                               targetAmount: convertedAmount)
    }
    
    private func updateAvailableCurrencies(data: [String:String]?) {
        guard let data else {return}
        availableCurrencies.onNext(data.keys.sorted(by: {$0 < $1}))
    }
    
    private func updateAvailableCurrencyRates(data: [CurrencyRate]?) {
        guard let data else {return}
        currencyRates.onNext(data)
    }
    
    func updateBaseAmount(data: Double?) {
        guard let data else {return}
        baseAmount.onNext(data)
    }
    
    func updateConvertedAmount(data: Double?) {
        guard let data else {return}
        convertedAmount.onNext(data)
    }
    
    func updateBaseCurrency(data: String?) {
        guard let data else {return}
        baseCurrency.onNext(data)
    }
    
    func updateTargetConversionCurrency(data: String?) {
        guard let data else {return}
        targetConversionCurrency.onNext(data)
    }
    
//    func addConversionToHistory(baseCurrency: String? , baseAmount: Double?, targetCurrency: String?, targetAmount: Double?) {
//        CacheManager.filterOldConversions()
//        guard let baseCurrency,
//                let baseAmount,
//                let targetCurrency,
//                let targetAmount else {return}
//        let conversion = Conversion(date: Date(),
//                                    baseCurrency: baseCurrency,
//                                    targetCurrency: targetCurrency,
//                                    baseAmount: baseAmount,
//                                    targetAmount: targetAmount)
//        var conversionHistory = CacheManager.conversionHistory
//        if conversionHistory.first(where: {$0 == conversion}) == nil,
//            baseCurrency != targetCurrency {
//            conversionHistory.append(conversion)
//        }
//        CacheManager.conversionHistory = conversionHistory
//    }
}
