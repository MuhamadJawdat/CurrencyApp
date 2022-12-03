//
//  ConversionHistoryTableViewCell.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 03/12/2022.
//

import UIKit

class ConversionHistoryTableViewCell: UITableViewCell {
    //base
    @IBOutlet private weak var baseCurrencyLabel: UILabel!
    @IBOutlet private weak var baseAmountLabel: UILabel!
    //target
    @IBOutlet private weak var targetCurrencyLabel: UILabel!
    @IBOutlet private weak var targetAmountLabel: UILabel!
    
    func updateCell(with conversion: Conversion) {
        //base
        baseCurrencyLabel.text = conversion.baseCurrency
        baseAmountLabel.text = "\(conversion.baseAmount)"
        //target
        targetCurrencyLabel.text = conversion.targetCurrency
        targetAmountLabel.text = "\(conversion.targetAmount)"
    }
}
