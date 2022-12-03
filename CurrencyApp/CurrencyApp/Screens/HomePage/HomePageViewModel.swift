//
//  HomePageViewModel.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation
import RxSwift

class HomePageViewModel {
    
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
    
    func setupViewModel() {
        initializeConversionSubscription()
        
        updateBaseCurrency(data: availableCurrenciesSortedKeys.first)
        updateTargetConversionCurrency(data: availableCurrenciesSortedKeys.first)
        updateBaseAmount(data: 1.0)
    }
    
    func initializeConversionSubscription() {
        let conversionInput = Observable.combineLatest(baseCurrency, targetConversionCurrency, baseAmount)
        let conversionInputSubscription = conversionInput.subscribe(onNext: { [weak self] (baseCurrency,targetConversionCurrency,baseAmount) in
            guard let self = self else {return}
            guard (CacheManager.storedRates.first {$0.baseCurrency == baseCurrency}) != nil else {
                self.currencyRates.subscribe(onNext: { _ in
                    self.convertValue(baseCurrency: baseCurrency, targetConversionCurrency: targetConversionCurrency, baseAmount: baseAmount)
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
            self.updateAvailableCurrencies(data: CacheManager.availableCurrencies)
            return
        }
        
        let urlString = "https://api.apilayer.com/fixer/symbols"
        NetworkFetcher.fetchFixerData(apiURL: urlString) { [weak self] (availableCurrencies: AvailableCurrencies) in
            guard let self = self,
                  let currencies = availableCurrencies.currencies else {
                print("No data available")
                return
            }
            self.updateAvailableCurrencies(data: currencies)
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
        
        let urlString = "https://api.apilayer.com/fixer/latest?symbols=\(CacheManager.availableCurrencies.keys.sorted(by: {$0 < $1}).joined(separator: ","))&base=\(currency)"
        NetworkFetcher.fetchFixerData(apiURL: urlString) { [weak self] (currencyRate: CurrencyRate) in
            guard let self = self,
                  let rates = currencyRate.rates,
                  !rates.isEmpty else {
                print("No data available")
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
        updateConvertedAmount(data: (baseAmount * rate).roundToDecimal(4))
    }
    
    func convertValue(baseCurrency: String, targetConversionCurrency: String, convertedAmount: Double) {
        guard let rate = CacheManager.storedRates.first(where: {$0.baseCurrency == baseCurrency})?.rates?.first(where: {$0.key == targetConversionCurrency})?.value else {
            print("Rate retrievable error")
            return
        }
        updateBaseAmount(data: (convertedAmount / rate).roundToDecimal(4))
    }
    
    private func updateAvailableCurrencies(data: [String:String]?) {
        guard let data = data else {return}
        availableCurrencies.onNext(data.keys.sorted(by: {$0 < $1}))
    }
    
    private func updateAvailableCurrencyRates(data: [CurrencyRate]?) {
        guard let data = data else {return}
        currencyRates.onNext(data)
    }
    
    func updateBaseAmount(data: Double?) {
        guard let data = data else {return}
        baseAmount.onNext(data)
    }
    
    func updateConvertedAmount(data: Double?) {
        guard let data = data else {return}
        convertedAmount.onNext(data)
    }
    
    func updateBaseCurrency(data: String?) {
        guard let data = data else {return}
        baseCurrency.onNext(data)
    }
    
    func updateTargetConversionCurrency(data: String?) {
        guard let data = data else {return}
        targetConversionCurrency.onNext(data)
    }
}

struct CurrencyRate: Codable {
    let baseCurrency: String?
    var rates: [String:Double]?
    
    enum CodingKeys: String, CodingKey {
        case baseCurrency = "base"
        case rates
    }
}
