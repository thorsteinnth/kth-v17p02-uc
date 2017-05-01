//
//  GeofenceService.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GeofenceService {

	// TODO Move LocationManager in here
	
	func addGeofence(geofence: Geofence) {
		// Adapted from: https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
		
		// TODO Throw custom exceptions
		// TODO Save geofence to persistent storage
		
		// Check if geofencing supported on this device
		if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
			print("Error: Geofencing not supported on this device")
			return
		}
		
		if CLLocationManager.authorizationStatus() != .authorizedAlways {
			print("Warning: Location permissions are needed for geofencing to work")
		}
		
		let region = covertGeofenceToCircularRegion(geofence: geofence)
		(UIApplication.shared.delegate as! AppDelegate).locationManager.startMonitoring(for: region)
		print("Started monitoring geofence")
	}
	
	func covertGeofenceToCircularRegion(geofence: Geofence) -> CLCircularRegion {
		let region = CLCircularRegion(center: geofence.center, radius: geofence.radius, identifier: geofence.sUUID)
		// TODO Allow user to set notify rules
		region.notifyOnEntry = true
		region.notifyOnExit = false
		return region
	}

}
