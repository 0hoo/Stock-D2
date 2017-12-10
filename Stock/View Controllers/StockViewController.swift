//
//  StockViewController.swift
//  Stock
//
//  Created by Kim Younghoo on 12/7/17.
//  Copyright © 2017 0hoo. All rights reserved.
//

import UIKit

class StockViewController: UIViewController {
    
    //[C11-7]
    let stock: Stock
    
    //[C11-4]
    @IBOutlet weak var tableView: UITableView!

    //[C11-8]
    init(stock: Stock) {
        self.stock = stock
        super.init(nibName: nil, bundle: nil)
    }

    //[C11-8]
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //[C11-9]
        title = stock.name
        
        tableView.backgroundColor = .backgroundView
        tableView.separatorColor = .separator
        tableView.hideBottomSeparator()
        //[C12-17]
        tableView.register(UINib(nibName: StockInfoTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: StockInfoTableViewCell.reuseIdentifier)
        //[C13-8]
        tableView.register(UINib(nibName: StockChartTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: StockChartTableViewCell.reuseIdentifier)
    }
}

//[C11-5]
extension StockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //[C11-5]
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //[C11-5]
        //return UITableViewCell()
        
        if indexPath.row == 0 {
            //[C12-18]
            let cell = tableView.dequeueReusableCell(withIdentifier: StockInfoTableViewCell.reuseIdentifier, for: indexPath) as! StockInfoTableViewCell
            cell.stock = stock
            return cell
        } else if indexPath.row == 1 {
            //[C13-9]
            let cell = tableView.dequeueReusableCell(withIdentifier: StockChartTableViewCell.reuseIdentifier, for: indexPath) as! StockChartTableViewCell
            cell.stock = stock
            return cell
        }
        return UITableViewCell()
    }
}

//[C11-6]
extension StockViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
