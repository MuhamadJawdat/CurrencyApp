//
//  BarGraph.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 04/12/2022.
//

import UIKit

class BarChartView: UIView {
    
    var barItems: [BarChartItem] = [BarChartItem]()
    
    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //common func to init our view
    func setupView(barItems: [BarChartItem]) {
        self.barItems = barItems
    }
    
    var barsStackView: UIStackView? {
        guard let highestValue = barItems.map({$0.value}).max() else {return nil}
        // Create a horizontal stack view to hold the bars
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        // Create a bar for each value
        barItems.forEach {
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
            barView.heightAnchor.constraint(equalToConstant: ((frame.size.height - (currencyTitleLabel.frame.height + 16)) * CGFloat($0.value) / CGFloat(highestValue))).isActive = true
            // Add the label and bar view to the bar stack view
            barStackView.addArrangedSubview(currencyTitleLabel)
            barStackView.addArrangedSubview(barView)
            // Add the bar stack view to the main stack view
            stackView.addArrangedSubview(barStackView)
        }
        
        return stackView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach {$0.removeFromSuperview()}
        if let barsStackView {
            addSubview(barsStackView)
        } else {
            let placeholderLabel = UILabel()
            placeholderLabel.text = "No Data Available"
            placeholderLabel.font = .systemFont(ofSize: 16, weight: .light)
            placeholderLabel.textAlignment = .center
            placeholderLabel.sizeToFit()
            placeholderLabel.frame.size.width = frame.width
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(placeholderLabel)
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
}
