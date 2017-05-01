//
//  CalendarEventGeofence.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import CoreLocation

class CalendarEventGeofence : Geofence {
	
	let calendarId: String
	
	init(name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, calendarId: String) {
		self.calendarId = calendarId
		super.init(name: name, center: center, radius: radius)
	}
	
	public override var description: String {
		return "CalendarEventGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - calendarId: \(calendarId)"
	}
}

