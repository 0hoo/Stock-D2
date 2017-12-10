import Foundation

class Group: Codable {
    static let didDelete = Notification.Name(rawValue: "Group.didDelete")
    
    var title: String
    var note: String?
    
    init(title: String, note: String?) {
        self.title = title
        self.note = note
    }
}
