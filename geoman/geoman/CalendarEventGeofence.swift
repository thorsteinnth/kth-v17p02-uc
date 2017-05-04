
import CoreLocation

class CalendarEventGeofence : Geofence {
	
	let calendarId: String
	
	init(center: CLLocationCoordinate2D, radius: CLLocationDistance, calendarId: String) {
		self.calendarId = calendarId
		super.init(center: center, radius: radius)
	}
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        calendarId = decoder.decodeObject(forKey: "calendarId") as! String
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.calendarId, forKey: "calendarId")
        super.encode(with: coder)
    }
	
	public override var description: String {
		return "CalendarEventGeofence: sUUID: \(sUUID) - center: \(center) - radius: \(radius) - calendarId: \(calendarId)"
	}
}

