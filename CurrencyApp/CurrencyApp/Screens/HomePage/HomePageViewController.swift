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
    @IBOutlet private weak var toTextField: UITextField!
    @IBOutlet private weak var toPickerView: UIPickerView!
    
    let viewModel = HomePageViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Setup
        title = "Convert Currency"
        
        //Auto hide keyboard
        hideKeyboardWhenTappedAround()
        preventKeyboardForCoveringUI()
        
        //setupPickerViews
        setupUI()
        
        viewModel.setupViewModel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetching data
        viewModel.fetchAvailableCurrencies()
    }
    
    @IBAction func SwitchFromToTapped(_ sender: Any) {
        viewModel.flipConversionSides(baseCurrency: viewModel.availableCurrenciesSortedKeys[self.fromPickerView.selectedRow(inComponent: 0)],
                                      targetCurrency: viewModel.availableCurrenciesSortedKeys[self.toPickerView.selectedRow(inComponent: 0)],
                                      convertedAmount: Double(toTextField.text ?? ""), baseAmount: Double(fromTextField.text ?? ""))
    }
    
}

extension HomePageViewController {
    private func setupUI() {
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
        fromPickerView.rx.modelSelected(String.self)
            .bind { currency in
                //do conversion
                self.viewModel.updateBaseCurrency(data: currency.first)
            }
            .disposed(by: disposeBag)
        
        viewModel.baseCurrency.subscribe(onNext: { currency in
            guard let indexOfCurrency = self.viewModel.availableCurrenciesSortedKeys.firstIndex(of: currency) else {return}
            DispatchQueue.main.async {
                self.fromPickerView.selectRow(indexOfCurrency, inComponent: 0, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        
        toPickerView.rx.modelSelected(String.self)
            .bind { currency in
                self.viewModel.updateTargetConversionCurrency(data: currency.first)
            }
            .disposed(by: disposeBag)
        
        viewModel.targetConversionCurrency.subscribe(onNext: { currency in
            guard let indexOfCurrency = self.viewModel.availableCurrenciesSortedKeys.firstIndex(of: currency) else {return}
            DispatchQueue.main.async {
                self.toPickerView.selectRow(indexOfCurrency, inComponent: 0, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.availableCurrencies.bind { availableCurrencies in
            guard let firstCurrency = availableCurrencies.first else {return}
            self.viewModel.fetchRatesForCurrency(currency:firstCurrency)
        }
        .disposed(by: disposeBag)
        
        //setup TextFields
        fromTextField.rx
            .controlEvent(.editingDidEnd)
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(fromTextField.rx.text)
            .subscribe(onNext: { query in
                guard let query = query else {return}
                self.viewModel.updateBaseAmount(data: Double(query))
            }).disposed(by: disposeBag)
        
        toTextField.rx
            .controlEvent(.editingDidEnd)
            .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
            .withLatestFrom(toTextField.rx.text)
            .subscribe(onNext: { [weak self] query in
                guard let self = self,
                      let query = query,
                let doubleValue = Double(query) else {return}
                self.viewModel.convertValue(baseCurrency: self.viewModel.availableCurrenciesSortedKeys[self.fromPickerView.selectedRow(inComponent: 0)],
                                            targetConversionCurrency: self.viewModel.availableCurrenciesSortedKeys[self.toPickerView.selectedRow(inComponent: 0)],
                                            convertedAmount: doubleValue)
            }).disposed(by: disposeBag)
        
        viewModel.convertedAmount.subscribe(onNext: { value in
            DispatchQueue.main.async {
                self.toTextField.text = "\(value)"
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.baseAmount.subscribe(onNext: { value in
            DispatchQueue.main.async {
                self.fromTextField.text = "\(value)"
            }
        })
        .disposed(by: disposeBag)
    }
}
