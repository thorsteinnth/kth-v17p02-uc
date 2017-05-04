
import CoreLocation

class Geofence : NSObject, NSCoding
{
	let sUUID: String
	var center: CLLocationCoordinate2D
	var radius: CLLocationDistance
	
	init(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		self.sUUID = UUID().uuidString
		self.center = center
		self.radius = radius
	}
	
	public override var description: String {
		return "Geofence: sUUID: \(sUUID) - center: \(center) - radius: \(radius)"
	}
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        sUUID = decoder.decodeObject(forKey: "suuid") as! String
        let latitude = decoder.decodeDouble(forKey: "latitude")
        let longitude = decoder.decodeDouble(forKey: "longitude")
        center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDouble(forKey: "radius")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.sUUID, forKey: "suuid")
        coder.encode(self.center.latitude, forKey: "latitude")
        coder.encode(self.center.longitude, forKey: "longitude")
        coder.encode(self.radius, forKey: "radius")
    }
}
