
import Foundation

struct CalendarEvent {
    
    let title: String
    let location: String
    let dateTime: String
    
    init(title: String, location: String, dateTime: String) {
        self.title = title
        self.location = location
        self.dateTime = dateTime
    }
}
