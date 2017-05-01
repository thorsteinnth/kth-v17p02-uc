//
//  CustomGeofence.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import CoreLocation

class CustomGeofence : Geofence {

	var customNotification: String
	
	init(name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, customNotification: String) {
		self.customNotification = customNotification
		super.init(name: name, center: center, radius: radius)
	}
	
	public func setCustomNotificationText(text: String) {
		self.customNotification = text
	}
	
	public override var description: String {
		return "CustomGeofence: sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - customNotification: \(customNotification)"
	}
}
