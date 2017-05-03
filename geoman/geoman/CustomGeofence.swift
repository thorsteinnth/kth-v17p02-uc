
import CoreLocation

class CustomGeofence : Geofence {

	var customNotification: String
	
	init(name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, customNotification: String) {
		self.customNotification = customNotification
		super.init(name: name, center: center, radius: radius)
	}
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        customNotification = decoder.decodeObject(forKey: "customNotification") as! String
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.customNotification, forKey: "customNotification")
        super.encode(with: coder)
    }
	
	public func setCustomNotificationText(text: String) {
		self.customNotification = text
	}
	
	public override var description: String {
		return "CustomGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - customNotification: \(customNotification)"
	}
}
