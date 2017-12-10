import UIKit

extension UITableView {
    func hideBottomSeparator() {
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 1))
    }
}
