import UIKit

extension UIColor {
    static var themeBlue: UIColor {
        return UIColor(hex: 0x2961BB)
    }
    
    static var textDark: UIColor {
        return UIColor(hex: 0x141517)
    }
    
    static var backgroundView: UIColor {
        return UIColor(hex: 0xf2f4f5)
    }
    
    static var separator: UIColor {
        return UIColor(hex: 0x0c141c).withAlphaComponent(0.1)
    }
    
    static var upRed: UIColor {
        return UIColor(hex: 0xd40400)
    }
    
    static var downBlue: UIColor {
        return UIColor(hex: 0x005dde)
    }
    
    @objc convenience init(hex: Int) {
        self.init(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: 1)
    }
}
