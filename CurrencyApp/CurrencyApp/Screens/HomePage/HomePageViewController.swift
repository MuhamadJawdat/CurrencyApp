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
            .bind { [weak self] currency in
                //do conversion
                self?.viewModel.updateBaseCurrency(data: currency.first)
            }
            .disposed(by: disposeBag)
        
        viewModel.baseCurrency.subscribe(onNext: { [weak self] currency in
            guard let indexOfCurrency = self?.viewModel.availableCurrenciesSortedKeys.firstIndex(of: currency) else {return}
            DispatchQueue.main.async {
                self?.fromPickerView.selectRow(indexOfCurrency, inComponent: 0, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        toPickerView.rx.modelSelected(String.self)
            .bind { [weak self] currency in
                self?.viewModel.updateTargetConversionCurrency(data: currency.first)
            }
            .disposed(by: disposeBag)
        
        viewModel.targetConversionCurrency.subscribe(onNext: { [weak self] currency in
            guard let indexOfCurrency = self?.viewModel.availableCurrenciesSortedKeys.firstIndex(of: currency) else {return}
            DispatchQueue.main.async {
                self?.toPickerView.selectRow(indexOfCurrency, inComponent: 0, animated: true)
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.availableCurrencies.bind { [weak self] availableCurrencies in
            guard let firstCurrency = availableCurrencies.first else {return}
            self?.viewModel.fetchRatesForCurrency(currency:firstCurrency)
        }
        .disposed(by: disposeBag)
        
        //setup TextFields
        fromTextField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(fromTextField.rx.text)
            .subscribe(onNext: { query in
                guard let query = query else {return}
                self.viewModel.updateBaseAmount(data: Double(query))
            }).disposed(by: disposeBag)
        
        toTextField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(toTextField.rx.text)
            .subscribe(onNext: { [weak self] query in
                guard let self,
                      let query,
                      let doubleValue = Double(query) else {return}
                self.viewModel.convertValue(baseCurrency: self.viewModel.availableCurrenciesSortedKeys[self.fromPickerView.selectedRow(inComponent: 0)],
                                            targetConversionCurrency: self.viewModel.availableCurrenciesSortedKeys[self.toPickerView.selectedRow(inComponent: 0)],
                                            convertedAmount: doubleValue)
            }).disposed(by: disposeBag)
        
        viewModel.convertedAmount.subscribe(onNext: { [weak self] value in
            DispatchQueue.main.async {
                self?.toTextField.text = "\(value)"
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.baseAmount.subscribe(onNext: { [weak self] value in
            DispatchQueue.main.async {
                self?.fromTextField.text = "\(value)"
            }
        })
        .disposed(by: disposeBag)
    }
}
