
import CoreLocation

class MetroGeofence : Geofence {
	
	let stationId: String
	
	init(name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, stationId: String) {
		self.stationId = stationId
		super.init(name: name, center: center, radius: radius)
	}
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        stationId = decoder.decodeObject(forKey: "stationId") as! String
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.stationId, forKey: "stationId")
        super.encode(with: coder)
    }
	
	public override var description: String {
		return "MetroGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - stationId: \(stationId)"
	}
}
