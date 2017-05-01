
import Foundation
import EventKit

class CalendarEventService {
    
    static func getNextCalendarEvents() -> [CalendarEvent] {
        
        var calendarEvents: [CalendarEvent] = []
        
        let eventStore = EKEventStore()
        
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        if authorizationStatus == EKAuthorizationStatus.authorized {
            
            let calendars = eventStore.calendars(for: EKEntityType.event)
            
            for calendar in calendars {
                
                if calendar.title == "KTH" {
                    
                    // Find events for the next 4 hours
                    let startDate = Date(timeIntervalSinceNow: 0)
                    let endDate = Date(timeIntervalSinceNow: 4*3600)
                    
                    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                    
                    let events = eventStore.events(matching: predicate)
                    
                    for event in events {
                        
                        let title = event.title
                        let location = event.location!
                        let dateTime = DateFormatter.localizedString(from: event.startDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
                        
                        let ev = CalendarEvent.init(title: title, location: location, dateTime: dateTime)
                        
                        calendarEvents.append(ev)
                    }
                }
            }
        }
        
        return calendarEvents
    }
}
