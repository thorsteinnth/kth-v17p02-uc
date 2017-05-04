
import CoreLocation

class MetroGeofence : Geofence {
	
	let stationId: String
	let name: String
	
	init(center: CLLocationCoordinate2D, radius: CLLocationDistance, stationId: String, name: String) {
		self.stationId = stationId
		self.name = name
		super.init(center: center, radius: radius)
	}
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        stationId = decoder.decodeObject(forKey: "stationId") as! String
		name = decoder.decodeObject(forKey: "name") as! String
        super.init(coder: decoder)
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(self.stationId, forKey: "stationId")
		coder.encode(self.name, forKey: "name")
        super.encode(with: coder)
    }
	
	public override var description: String {
		return "MetroGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - stationId: \(stationId)"
	}
}
