//
//  Geofence.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 28/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import CoreLocation

class Geofence : CustomStringConvertible
{
	let sUUID: String
	var name: String
	var center: CLLocationCoordinate2D
	var radius: CLLocationDistance
	
	init(name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		self.sUUID = UUID().uuidString
		self.name = name
		self.center = center
		self.radius = radius
	}
	
	public var description: String {
		return "Geofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius)"
	}
}
