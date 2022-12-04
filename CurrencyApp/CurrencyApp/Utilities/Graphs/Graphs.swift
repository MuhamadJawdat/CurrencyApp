//
//  BarGraph.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 04/12/2022.
//

import UIKit

struct Graphs {
    
    static func makeBarChart(bars: [BarChartItem], size: CGSize) -> UIView? {
        guard let highestValue = bars.map({$0.value}).max() else {return nil}
        // Create a horizontal stack view to hold the bars
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        // Create a bar for each value
        bars.forEach {
            // Create a vertical stack view to represent the bar
            let barStackView = UIStackView()
            barStackView.axis = .vertical
            
            // Create a label to show the value of the bar
            let currencyTitleLabel = UILabel()
            currencyTitleLabel.text = "\($0.title)"//"\($0.title)\n(\(Int($0.value)) conversions)"
            currencyTitleLabel.textAlignment = .center
            currencyTitleLabel.backgroundColor = .systemFill
            currencyTitleLabel.adjustsFontSizeToFitWidth = true
            currencyTitleLabel.minimumScaleFactor = 0.5
            currencyTitleLabel.font = .systemFont(ofSize: 16, weight: .light)
            currencyTitleLabel.numberOfLines = 0
            currencyTitleLabel.sizeToFit()
            
            // Create a view to represent the bar itself
            let barView = UIView()
            barView.backgroundColor = .systemGreen
            barView.alpha = CGFloat($0.value) / CGFloat(highestValue)
            //barView.heightAnchor.constraint(equalToConstant: CGFloat($0.value)).isActive = true
            barView.heightAnchor.constraint(equalToConstant: ((size.height - (currencyTitleLabel.frame.height + 16)) * CGFloat($0.value) / CGFloat(highestValue))).isActive = true
            
            // Add the label and bar view to the bar stack view
            barStackView.addArrangedSubview(currencyTitleLabel)
            barStackView.addArrangedSubview(barView)
            // Add the bar stack view to the main stack view
            stackView.addArrangedSubview(barStackView)
        }
        
        return stackView
    }
}
