//
//  MapPin.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 02/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import Foundation
import MapKit

class MapPin : NSObject, MKAnnotation {

	let title: String?
	let subtitle: String?
	let coordinate: CLLocationCoordinate2D
	let geofenceId: String
	
	init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, geofenceId: String) {
		self.title = title
		self.subtitle = subtitle
		self.coordinate = coordinate
		self.geofenceId = geofenceId
		super.init()
	}
}
