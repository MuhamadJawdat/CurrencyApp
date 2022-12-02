//
//  ViewController.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import UIKit

class HomePage: UIViewController {
    
    let viewModel = HomePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.fetchAvailableCurrencies() {
            print(self.viewModel.availableCurrencies)
        }
    }
}

