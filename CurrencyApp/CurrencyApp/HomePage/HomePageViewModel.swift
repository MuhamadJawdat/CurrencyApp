//
//  HomePageViewModel.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation
import RxSwift

class HomePageViewModel {
    
    var availableCurrencies = [String:String]()
    
    func fetchAvailableCurrencies(onCompletion:@escaping ()->()) {
        let urlString = "https://api.apilayer.com/fixer/symbols"
        NetworkFetcher.fetchFixerData(apiURL: urlString) { (availableCurrencies: AvailableCurrencies) in
            self.availableCurrencies = availableCurrencies.currencies ?? [:]
            onCompletion()
        }
    }
}

struct AvailableCurrencies: Codable {
    var currencies: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case currencies = "symbols"
    }
}
