//
//  HomePageViewModel.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation
import RxSwift

class HomePageViewModel {
    
    var availableCurrencies = PublishSubject<[String:String]>()
    
    func fetchAvailableCurrencies() {
        
        guard CacheManager.availableCuurencies.isEmpty else {
            self.updateAvailableCurrencies(data: CacheManager.availableCuurencies)
            return
        }
        
        let urlString = "https://api.apilayer.com/fixer/symbols"
        NetworkFetcher.fetchFixerData(apiURL: urlString) { (availableCurrencies: AvailableCurrencies) in
            guard let currencies = availableCurrencies.currencies else {return}
            self.updateAvailableCurrencies(data: currencies)
            CacheManager.availableCuurencies = currencies
        }
    }
    
    private func updateAvailableCurrencies(data: [String:String]?) {
        guard let data = data else {return}
        self.availableCurrencies.onNext(data)
        self.availableCurrencies.onCompleted()
    }
}
