//
//  Geofence.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 28/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import CoreLocation

class Geofence
{
	var sUUID: String
	var center: CLLocationCoordinate2D
	var radius: CLLocationDistance
	
	init(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		self.sUUID = UUID().uuidString
		self.center = center
		self.radius = radius
	}
}
