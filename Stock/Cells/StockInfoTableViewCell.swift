//
//  StockInfoTableViewCell.swift
//  Stock
//
//  Created by Kim Younghoo on 12/7/17.
//  Copyright © 2017 0hoo. All rights reserved.
//

import UIKit

class StockInfoTableViewCell: UITableViewCell {
    
    //[C12-14]
    @IBOutlet weak var stockCodeLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var priceDiffLabel: UILabel!
    
    //[C12-16]
    var stock: Stock? {
        didSet {
            guard let stock = stock else { return }
            var stockCodeText = stock.code
            if let exchange = stock.exchange {
                stockCodeText += " | \(exchange)"
            }
            
            stockCodeLabel.text = stockCodeText
            currentPriceLabel.text = "KRW \(stock.priceText)"
            priceDiffLabel.text = stock.priceDiffText
            if stock.isPriceKeep {
                currentPriceLabel.textColor = .textDark
                priceDiffLabel.textColor = .darkGray
            } else if stock.isPriceUp {
                currentPriceLabel.textColor = .upRed
                priceDiffLabel.textColor = .upRed
            } else {
                currentPriceLabel.textColor = .downBlue
                priceDiffLabel.textColor = .downBlue
            }
        }
    }
    
    //[C12-15]
    override func prepareForReuse() {
        super.prepareForReuse()
        stockCodeLabel.text = nil
        currentPriceLabel.text = nil
        priceDiffLabel.text = nil
    }

    //[C12-15]
    override func awakeFromNib() {
        super.awakeFromNib()
        stockCodeLabel.text = nil
        currentPriceLabel.text = nil
        priceDiffLabel.text = nil
    }
}
