
import CoreLocation

class MetroGeofence : Geofence {
	
	let stationId: String
	let name: String
	var showNotifications: Bool
	
	init(center: CLLocationCoordinate2D, radius: CLLocationDistance, stationId: String, name: String) {
		self.stationId = stationId
		self.name = name
		self.showNotifications = true
		super.init(center: center, radius: radius)
	}
	
	func setShowNotifications(show: Bool) {
		self.showNotifications = show
	}
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        stationId = decoder.decodeObject(forKey: "stationId") as! String
		name = decoder.decodeObject(forKey: "name") as! String
		showNotifications = Bool(decoder.decodeBool(forKey: "showNotifications"))
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.stationId, forKey: "stationId")
		coder.encode(self.name, forKey: "name")
		coder.encode(self.showNotifications, forKey: "showNotifications")
        super.encode(with: coder)
    }
	
	public override var description: String {
		return "MetroGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - stationId: \(stationId) - showNotifications: \(showNotifications)"
	}
}
