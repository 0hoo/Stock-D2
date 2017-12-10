//
//  StocksViewController.swift
//  Stock
//
//  Created by Kim Younghoo on 12/5/17.
//  Copyright © 2017 0hoo. All rights reserved.
//

import UIKit
//[C7-1]
import SVProgressHUD
import Alamofire
import Kanna

class StocksViewController: UIViewController {
    
    //[C2-4]
    let segmentedControl = UISegmentedControl(items: ["그룹", "종목"])
    
    //[C4-4]
    @IBOutlet weak var tableView: UITableView!
    
    //[C4-6]
    var stocks: [Stock] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //[C1-2]
        //title = "종목"
        
        //[C2-5]
        navigationItem.titleView = segmentedControl
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        //[C4-1]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshStocks))
        //[C4-2]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-add"), style: .plain, target: self, action: #selector(newStock))
        
        tableView.separatorColor = .separator
        //[C9-20]
        tableView.register(UINib(nibName: StockTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: StockTableViewCell.reuseIdentifier)
        //[C4-9]
        tableView.hideBottomSeparator()
        
        //[C10-4]
        reload()
    }
    
    //[C2-8]
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        segmentedControl.selectedSegmentIndex = 1
    }
    
    //[C2-6]
    @objc func segmentedControlChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            tabBarController?.selectedIndex = segmentedControl.selectedSegmentIndex
        }
    }
    
    //[C4-2]
    @objc func newStock() {
        //[C5-2]
        let alertController = UIAlertController(title: "새 종목", message: "종목코드를 입력하세요", preferredStyle: .alert)
        //[C5-3]
        alertController.addTextField { (textField) in
            textField.placeholder = "종목코드"
        }
        //[C5-4]
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //[C5-5]
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let code = alertController.textFields?[0].text, !code.isEmpty else { return }
            self?.searchStock(code: code)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    //[C5-6]
    func searchStock(code: String) {
        //[C7-2]
        SVProgressHUD.show()
        //[C7-3]
        let siteUrl = "http://finance.daum.net/item/main.daum?code=" + code
        Alamofire.request(siteUrl).responseString { response in
            //[C7-4]
            SVProgressHUD.dismiss()

            //[C8-1]
            guard let html = response.result.value else { return }
            guard let doc = try? HTML(html: html, encoding: .utf8) else { return }
            
            //[C8-9]
            guard let titleElement = doc.at_css("#topWrap > div.topInfo > h2") else { return }
            //[C8-10]
            guard let title = titleElement.content else { return }
            //[C8-11]
            guard let priceElement = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(1) > em") else { return }
            guard let priceString = priceElement.content else { return }
            //[C8-13]
            guard let price = Double(priceString.replacingOccurrences(of: ",", with: "")) else { return }

            //[C8-15]
            let priceKeep = priceElement.className?.hasSuffix("keep") == true
            let priceUp = priceElement.className?.hasSuffix("up") == true
            
            //[C8-16]
            let priceDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(2) > span")?.content ?? ""
            //[C8-17]
            let priceDiff = Double(priceDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
            
            //[C8-18]
            var rateDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(3) > span")?.content ?? ""
            if rateDiffString.hasSuffix("％") || rateDiffString.hasSuffix("%") {
                rateDiffString = String(rateDiffString.dropLast())
            }
            if rateDiffString.hasPrefix("+") || rateDiffString.hasPrefix("-") {
                rateDiffString = String(rateDiffString.dropFirst())
            }
            let rateDiff = Double(rateDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
            
            //[C8-19]
            let exchange = doc.at_css("#topWrap > div.topInfo > ul.list_stockinfo > li:nth-child(2) > a")?.content

            //[C8-20]
            let stock = Stock(name: title, code: code, price: price, isPriceUp: priceUp, isPriceKeep: priceKeep, priceDiff: priceDiff, rateDiff: rateDiff, exchange: exchange)
            //[C8-21]
            stock.dayChartImageUrl = URL(string: doc.at_css("#stockGraphBody1")?["src"] ?? "")
            stock.monthChartImageUrl = URL(string: doc.at_css("#stockGraphBody2")?["src"] ?? "")
            stock.threeMonthsChartImageUrl = URL(string: doc.at_css("#stockGraphBody3")?["src"] ?? "")
            stock.yearChartImageUrl = URL(string: doc.at_css("#stockGraphBody4")?["src"] ?? "")
            stock.threeYearsChartImageUrl = URL(string: doc.at_css("#stockGraphBody5")?["src"] ?? "")

            //[C8-22]
            self.stocks.append(stock)
            //[C10-5]
            self.saveStocks()
            self.tableView.reloadData()
        }
    
//[C14-3]
//        parseStock(code: code) { stock in
//            self.stocks.append(stock)
//            self.saveStocks()
//            self.tableView.reloadData()
//        }
    }
    
    //[C14-3]
    func parseStock(code: String, success: @escaping ((Stock) -> Void)) {
        let siteUrl = "http://finance.daum.net/item/main.daum?code=" + code
        Alamofire.request(siteUrl).responseString { response in
            SVProgressHUD.dismiss()
            
            guard let html = response.result.value else { return }
            guard let doc = try? HTML(html: html, encoding: .utf8) else { return }
            guard let titleElement = doc.at_css("#topWrap > div.topInfo > h2") else { return }
            guard let title = titleElement.content else { return }
            guard let priceElement = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(1) > em") else { return }
            guard let priceString = priceElement.content else { return }
            guard let price = Double(priceString.replacingOccurrences(of: ",", with: "")) else { return }
            
            let priceKeep = priceElement.className?.hasSuffix("keep") == true
            let priceUp = priceElement.className?.hasSuffix("up") == true
            let priceDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(2) > span")?.content ?? ""
            let priceDiff = Double(priceDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
            var rateDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(3) > span")?.content ?? ""
            if rateDiffString.hasSuffix("％") || rateDiffString.hasSuffix("%") {
                rateDiffString = String(rateDiffString.dropLast())
            }
            if rateDiffString.hasPrefix("+") || rateDiffString.hasPrefix("-") {
                rateDiffString = String(rateDiffString.dropFirst())
            }
            let rateDiff = Double(rateDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
            let exchange = doc.at_css("#topWrap > div.topInfo > ul.list_stockinfo > li:nth-child(2) > a")?.content
            
            let stock = Stock(name: title, code: code, price: price, isPriceUp: priceUp, isPriceKeep: priceKeep, priceDiff: priceDiff, rateDiff: rateDiff, exchange: exchange)
            stock.dayChartImageUrl = URL(string: doc.at_css("#stockGraphBody1")?["src"] ?? "")
            stock.monthChartImageUrl = URL(string: doc.at_css("#stockGraphBody2")?["src"] ?? "")
            stock.threeMonthsChartImageUrl = URL(string: doc.at_css("#stockGraphBody3")?["src"] ?? "")
            stock.yearChartImageUrl = URL(string: doc.at_css("#stockGraphBody4")?["src"] ?? "")
            stock.threeYearsChartImageUrl = URL(string: doc.at_css("#stockGraphBody5")?["src"] ?? "")
            success(stock)
        }
    }
    
    //[C4-1]
    @objc func refreshStocks() {
        //[C14-1]
        var updated = 0
        
        if stocks.count > 0 {
            SVProgressHUD.show()
        }
        
        for stock in stocks {
            Alamofire.request("http://finance.daum.net/item/main.daum?code=" + stock.code).responseString { response in
                guard let html = response.result.value else { return }
                guard let doc = try? HTML(html: html, encoding: .utf8) else { return }
                guard let priceElement = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(1) > em") else { return }
                guard let priceString = priceElement.content else { return }
                guard let price = Double(priceString.replacingOccurrences(of: ",", with: "")) else { return }

                let priceKeep = priceElement.className?.hasSuffix("keep") == true
                let priceUp = priceElement.className?.hasSuffix("up") == true
                let priceDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(2) > span")?.content ?? ""
                let priceDiff = Double(priceDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
                var rateDiffString = doc.at_css("#topWrap > div.topInfo > ul.list_stockrate > li:nth-child(3) > span")?.content ?? ""
                if rateDiffString.hasSuffix("％") || rateDiffString.hasSuffix("%") {
                    rateDiffString = String(rateDiffString.dropLast())
                }
                if rateDiffString.hasPrefix("+") || rateDiffString.hasPrefix("-") {
                    rateDiffString = String(rateDiffString.dropFirst())
                }
                let rateDiff = Double(rateDiffString.replacingOccurrences(of: ",", with: "")) ?? 0
                let exchange = doc.at_css("#topWrap > div.topInfo > ul.list_stockinfo > li:nth-child(2) > a")?.content

                stock.price = price
                stock.isPriceKeep = priceKeep
                stock.isPriceUp = priceUp
                stock.priceDiff = priceDiff
                stock.rateDiff = rateDiff
                stock.exchange = exchange
                stock.dayChartImageUrl = URL(string: doc.at_css("#stockGraphBody1")?["src"] ?? "")
                stock.monthChartImageUrl = URL(string: doc.at_css("#stockGraphBody2")?["src"] ?? "")
                stock.threeMonthsChartImageUrl = URL(string: doc.at_css("#stockGraphBody3")?["src"] ?? "")
                stock.yearChartImageUrl = URL(string: doc.at_css("#stockGraphBody4")?["src"] ?? "")
                stock.threeYearsChartImageUrl = URL(string: doc.at_css("#stockGraphBody5")?["src"] ?? "")

                //[C14-2]
                updated += 1
                if updated == self.stocks.count {
                    SVProgressHUD.dismiss()
                    self.saveStocks()
                    self.reload()
                }
            }
        }
        
//[C14-3]
//        for stock in stocks {
//            parseStock(code: stock.code) { updatedStock in
//                stock.price = updatedStock.price
//                stock.isPriceKeep = updatedStock.isPriceKeep
//                stock.isPriceUp = updatedStock.isPriceUp
//                stock.priceDiff = updatedStock.priceDiff
//                stock.rateDiff = updatedStock.rateDiff
//                stock.exchange = updatedStock.exchange
//                stock.dayChartImageUrl = updatedStock.dayChartImageUrl
//                stock.monthChartImageUrl = updatedStock.monthChartImageUrl
//                stock.threeMonthsChartImageUrl = updatedStock.threeMonthsChartImageUrl
//                stock.yearChartImageUrl = updatedStock.yearChartImageUrl
//                stock.threeYearsChartImageUrl = updatedStock.threeYearsChartImageUrl
//                updated += 1
//                if updated == self.stocks.count {
//                    SVProgressHUD.dismiss()
//                    self.saveStocks()
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }
    
    //[C10-2]
    func saveStocks() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(stocks), forKey: "stocks")
    }
    
    //[C10-3]
    func reload() {
        if let data = UserDefaults.standard.object(forKey: "stocks") as? Data {
            if let stocks = try? PropertyListDecoder().decode([Stock].self, from: data) {
                self.stocks = stocks
            }
        }
    }
}

//[C4-7]
extension StocksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //[C4-7]
        //let cell = UITableViewCell()
        //cell.textLabel?.text = stocks[indexPath.row].name
        //return cell
        
        //[C9-21]
        let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.reuseIdentifier, for: indexPath) as! StockTableViewCell
        cell.stock = stocks[indexPath.row]
        //[C9-22]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

//[C4-8]
extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //[C11-10]
        navigationController?.pushViewController(StockViewController(stock: stocks[indexPath.row]), animated: true)
    }
}


