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
            self.updateAvailableCurrencies(data: availableCurrencies.currencies)
        }
    }
    
    private func updateAvailableCurrencies(data: [String:String]?) {
        guard let data = data else {return}
        self.availableCurrencies.onNext(data)
        self.availableCurrencies.onCompleted()
    }
}

struct AvailableCurrencies: Codable {
    var currencies: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case currencies = "symbols"
    }
}
