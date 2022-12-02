//
//  ViewController.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import UIKit
import RxCocoa
import RxSwift

class HomePageViewController: UIViewController {
    // Base Currency
    @IBOutlet private weak var fromPickerView: UIPickerView!
    @IBOutlet private weak var fromTextField: UITextField!
    
    // target Currency
    @IBOutlet private weak var toPickerView: UIPickerView!
    
    let viewModel = HomePageViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Setup
        title = "Convert Currency"
        
        //Auto hide keyboard
        hideKeyboardWhenTappedAround()
        
        //setupPickerViews
        setupPickerViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetching data
        viewModel.fetchAvailableCurrencies()
    }
    
    @IBAction func SwitchFromToTapped(_ sender: Any) {
        print("==> tapped")
    }
    
}

extension HomePageViewController {
    private func setupPickerViews() {
        //setup data
        viewModel.availableCurrencies.bind(to: fromPickerView.rx.itemTitles) { (_, currency) in
            currency
        }
        .disposed(by: disposeBag)
        
        viewModel.availableCurrencies.bind(to: toPickerView.rx.itemTitles) { (_, currency) in
            currency
        }
        .disposed(by: disposeBag)
        
        //setup onSelection
        fromPickerView.rx.itemSelected
            .subscribe { event in
                switch event {
                case .next(let selected):
                    print("\(selected) is Selected")
                default: break
                }
            }
            .disposed(by: disposeBag)
        
        toPickerView.rx.itemSelected
            .subscribe { event in
                switch event {
                case .next(let selected):
                    print("\(selected) is Selected")
                default: break
                }
            }
            .disposed(by: disposeBag)
        
        //        viewModel.availableCurrencies.bind { availableCurrencies in
        //            print("available currencies fetched: \(availableCurrencies)")
        //        }
    }
}
