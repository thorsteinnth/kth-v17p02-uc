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
	enum GeofenceType: String {
		case metro, calendar, custom
	}
	
	let sUUID: String
	let type: GeofenceType
	var name: String
	var center: CLLocationCoordinate2D
	var radius: CLLocationDistance
	var customNotification: String
	
	init(type: GeofenceType, name: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		self.sUUID = UUID().uuidString
		self.type = type
		self.name = name
		self.center = center
		self.radius = radius
		self.customNotification = ""
	}
	
	public var description: String {
		return "Geofence: type: \(type) - sUUID: \(sUUID) - name: \(name) - center: \(center) - radius: \(radius) - customNotification: \(customNotification)"
	}
	
	public func setCustomNotificationText(text: String) {
		self.customNotification = text
	}
}
