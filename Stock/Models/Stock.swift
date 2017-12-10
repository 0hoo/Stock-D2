import Foundation

//[C9-16]
class Formatters {
    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}

//[C10-1]
class Stock: Codable {
    let name: String
    let code: String
    var price: Double
    var isPriceUp: Bool
    var isPriceKeep: Bool
    var priceDiff: Double
    var rateDiff: Double
    var exchange: String?
    var amount: Int
    var groupTitle: String?
    var dayChartImageUrl: URL?
    var monthChartImageUrl: URL?
    var threeMonthsChartImageUrl: URL?
    var yearChartImageUrl: URL?
    var threeYearsChartImageUrl: URL?
    
    init(name: String, code: String, price: Double, isPriceUp: Bool, isPriceKeep: Bool, priceDiff: Double, rateDiff: Double, exchange: String?, amount: Int = 0) {
        self.name = name
        self.code = code
        self.price = price
        self.isPriceUp = isPriceUp
        self.isPriceKeep = isPriceKeep
        self.priceDiff = priceDiff
        self.rateDiff = rateDiff
        self.exchange = exchange
        self.amount = amount
    }
    
    //[C9-17]
    var priceText: String {
        return Formatters.price.string(from: NSNumber(value: price)) ?? ""
    }

    //[C9-18]
    var priceDiffText: String {
        let diffText = Formatters.price.string(from: NSNumber(value: priceDiff)) ?? ""

        if isPriceKeep {
            return "0 +0.00%"
        } else if isPriceUp {
            return "▲ \(diffText) +\(rateDiff)%"
        } else {
            return "▼ \(diffText) -\(rateDiff)%"
        }
    }
}
