//
//  HomePageNetworking.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 04/12/2022.
//

import Foundation

protocol FixerAPINetworkable {
    //fetches all available currencies
    func getAvailableCurrencies(onCompletion: @escaping ([String : String])->())
    //fetches the rates for base currency against all requested currencies
    func getCurrencyRates(_ getCurrencyRatesRequest: GetCurrencyRatesRequest, onCompletion: @escaping (CurrencyRate)->())
}

extension FixerAPINetworkable {
    func getAvailableCurrencies(onCompletion: @escaping ([String : String])->()) {
        let urlString = "https://api.apilayer.com/fixer/symbols"
        NetworkFetcher.fetchFixerData(apiURL: urlString) { (availableCurrencies: AvailableCurrencies) in
            guard let currencies = availableCurrencies.currencies else {
                print("No (getAvailableCurrencies) data available")
                return
            }
            onCompletion(currencies)
        }
    }
    
    func getCurrencyRates(_ getCurrencyRatesRequest: GetCurrencyRatesRequest, onCompletion: @escaping (CurrencyRate)->()) {
        let urlString = "https://api.apilayer.com/fixer/latest?symbols=\(getCurrencyRatesRequest.targetCurrencies.sorted(by: {$0 < $1}).joined(separator: ","))&base=\(getCurrencyRatesRequest.baseCurrency)"
        NetworkFetcher.fetchFixerData(apiURL: urlString) { (currencyRate: CurrencyRate) in
            guard let rates = currencyRate.rates,
                  !rates.isEmpty else {
                print("No (getCurrencyRates) data available")
                return
            }
            onCompletion(currencyRate)
        }
    }
    
}

struct GetCurrencyRatesRequest {
    let baseCurrency: String
    let targetCurrencies: [String]
}
