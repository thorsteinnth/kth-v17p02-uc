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

class GeofenceService : NSObject {	// NOTE: Have to subclass NSObject for the extension to work

	let locationManager = CLLocationManager()
	var geofenceDict = [String: Geofence]()
	
	override init() {
		super.init()
		// Location manager setup
		self.locationManager.requestAlwaysAuthorization()
		if (CLLocationManager.locationServicesEnabled()) {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
		}
	}
	
	func addGeofence(geofence: Geofence) {
		// Adapted from: https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
		
		// TODO Throw custom exceptions
		
		// Check if geofencing supported on this device
		if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
			print("Error: Geofencing not supported on this device")
			return
		}
		
		if CLLocationManager.authorizationStatus() != .authorizedAlways {
			print("Warning: Location permissions are needed for geofencing to work")
		}
		
		let region = covertGeofenceToCircularRegion(geofence: geofence)
		locationManager.startMonitoring(for: region)
		
		// Save geofence
		// TODO Save to persistent storage
		geofenceDict[geofence.sUUID] = geofence
	}
	
	func getAllGeofences() -> Array<Geofence> {
		let geofences = [Geofence](geofenceDict.values)
		return geofences
	}
	
	func covertGeofenceToCircularRegion(geofence: Geofence) -> CLCircularRegion {
		let region = CLCircularRegion(center: geofence.center, radius: geofence.radius, identifier: geofence.sUUID)
		// TODO Allow user to set notify rules
		region.notifyOnEntry = true
		region.notifyOnExit = false
		return region
	}
	
	func displayNotificationForGeofence(geofence: Geofence) {
		
		let notificationService = (UIApplication.shared.delegate as! AppDelegate).notificationService
		
		var body = ""
		switch (geofence) {
		case is CalendarEventGeofence:
			let calendarEventGeofence = geofence as! CalendarEventGeofence
			body = "Should show calendar event from calendar with ID: \(calendarEventGeofence.calendarId)"
		case is CustomGeofence:
			let customGeofence = geofence as! CustomGeofence
			body = customGeofence.customNotification
		case is MetroGeofence:
			let metroGeofence = geofence as! MetroGeofence
			body = "Should show metro information for station with ID: \(metroGeofence.stationId)"
		default:
			print("GeofenceService.displayNotificationForGeofence - Unknown geofence type: \(type(of: geofence))")
			body = ""
		}
		
		notificationService.showLocalNotification(
			title: "Entered geofence",
			subTitle: geofence.name,
			body: body
		)
	}
}

extension GeofenceService: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		// The authorization state for the application changed
		var locationStatus = String()
		switch status {
		case CLAuthorizationStatus.restricted:
			locationStatus = "Restricted"
		case CLAuthorizationStatus.denied:
			locationStatus = "Denied"
		case CLAuthorizationStatus.notDetermined:
			locationStatus = "Not determined"
		case CLAuthorizationStatus.authorizedAlways:
			locationStatus = "Authorized always"
		case CLAuthorizationStatus.authorizedWhenInUse:
			locationStatus = "Authorized when in use"
		default:
			locationStatus = "Unknown location authorization status"
		}
		print("CLLocationManager.didChangeAuthorization: \(locationStatus)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		// The latest location is at the end of the array
		if let latestLocation = locations.last {
			// The latest location is not nil
			//print("CLLocationManager.didUpdateLocations: \(latestLocation)")
		}
		else {
			print("CLLocationManager.didUpdateLocations: nil")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
		print("CLLocationManager.didStartMonitoringForRegion: \(region)")
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("CLLocationManager.monitoringDidFailForRegion: \(String(describing: region)) with error: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("CLLocationManager.didFailWithError: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		
		print("CLLocationManager.didEnterRegion: \(region)")
		
		if let geofence = geofenceDict[region.identifier] {
			print("CLLocationManager.didEnterRegion: Just entered geofence: \(geofence)")
			displayNotificationForGeofence(geofence: geofence)
		}
		else {
			print("CLLocationManager.didEnterRegion: Could not find geofence for region: \(region)")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("CLLocationManager.didExitRegion: \(region)")
	}
}

