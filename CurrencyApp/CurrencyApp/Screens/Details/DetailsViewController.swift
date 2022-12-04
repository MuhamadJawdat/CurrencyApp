//
//  DetailsViewController.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

final class DetailsViewController: UIViewController {

    @IBOutlet private weak var recentConversionsTableView: UITableView!
    @IBOutlet private weak var otherCurrenciesTableView: UITableView!
    
    var viewModel = DetailsViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recentConversionsTableView.rx.setDelegate(self).disposed(by: disposeBag)
        otherCurrenciesTableView.rx.setDelegate(self).disposed(by: disposeBag)
        setupUI()
        viewModel.setupData()
    }
    
    private func setupUI() {
        setupRecentConversionsTableView()
        setupOtherCurrenciesTableView()
    }
    
    private func setupRecentConversionsTableView() {
        
        // Create the data source for the table view.
        let dataSource = RxTableViewSectionedReloadDataSource<ConversionHistoryDay>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ConversionHistoryTableViewCell", for: indexPath) as? ConversionHistoryTableViewCell
                cell?.updateCell(with: item)
                return cell ?? UITableViewCell()
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource[index].day
            }
        )
        
        // Bind the table view data source to the sections observable.
        viewModel.recentConversions
            .bind(to: recentConversionsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        recentConversionsTableView.rx.modelSelected(Conversion.self).subscribe(onNext: { [weak self] conversion in
            self?.viewModel.generateOtherCurrencyConversions(baseCurrency: conversion.baseCurrency,
                                                             previousTargetCurrency: conversion.targetCurrency,
                                                             baseAmount: conversion.baseAmount)
        }).disposed(by: disposeBag)
        
    }
    
    private func setupOtherCurrenciesTableView() {
        viewModel.otherConversions.bind(to: otherCurrenciesTableView.rx.items(cellIdentifier: "OtherCurrencyTableViewCell",
                                                                              cellType: ConversionHistoryTableViewCell.self)) { (row,item,cell) in
            cell.updateCell(with: item)
        }.disposed(by: disposeBag)
    }
}

extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
