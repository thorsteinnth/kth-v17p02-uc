//
//  MetroGeofence.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import CoreLocation

class MetroGeofence : Geofence {
	
	let stationId: String
	
	init(name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, stationId: String) {
		self.stationId = stationId
		super.init(name: name, center: center, radius: radius)
	}
	
	public override var description: String {
		return "MetroGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - stationId: \(stationId)"
	}
}
