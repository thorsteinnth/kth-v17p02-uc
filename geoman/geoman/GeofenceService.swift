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

class GeofenceService : Service {

	let locationManager = CLLocationManager()
	var pendingLocationManagerRequests = [String : AsyncCompletionHandler]()
	
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
	
	func addGeofence(geofence: Geofence, onCompletion: @escaping AsyncCompletionHandler) {
		// Adapted from: https://www.raywenderlich.com/136165/core-location-geofencing-tutorial
		
		// Check if geofencing supported on this device
		if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
			print("Error: Geofencing not supported on this device")
			onCompletion(false, "Geofencing is not supported on this device")
			return
		}
		
		// Check if we have the needed permissions
		if CLLocationManager.authorizationStatus() != .authorizedAlways {
			print("Error: Location permissions are needed for geofencing to work")
			onCompletion(false, "Location permissions are needed for geofencing to work")
			return
		}
		
		// Register geofence with location manager
		// Add geofence to pending set
		pendingLocationManagerRequests[geofence.sUUID] = {(success: Bool, message: String) -> Void in
			if success {
				self.saveGeofence(geofence: geofence)
				onCompletion(true, message)
			}
			else {
				onCompletion(false, message)
			}
		}
		let region = covertGeofenceToCircularRegion(geofence: geofence)
		locationManager.startMonitoring(for: region)
	}
	
	func saveGeofence(geofence: Geofence) {
		
		if let data = UserDefaults.standard.object(forKey: "geofenceDict") as? NSData {
			var geofenceDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [String: Geofence]
			geofenceDict[geofence.sUUID] = geofence
			let data = NSKeyedArchiver.archivedData(withRootObject: geofenceDict)
			UserDefaults.standard.set(data, forKey: "geofenceDict")
		}
		else {
			var geofenceDict = [String: Geofence]()
			geofenceDict[geofence.sUUID] = geofence
			let data = NSKeyedArchiver.archivedData(withRootObject: geofenceDict)
			UserDefaults.standard.set(data, forKey: "geofenceDict")
		}
		
		print("Saved geofence: \(geofence)")
	}
	
	func getAllGeofences() -> Array<Geofence> {
		
        if let data = UserDefaults.standard.object(forKey: "geofenceDict") as? NSData {
            let geofenceDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [String: Geofence]
            let geofences = [Geofence](geofenceDict.values)
            return geofences
        }
        else {
            return []
        }
	}
	
	func covertGeofenceToCircularRegion(geofence: Geofence) -> CLCircularRegion {
		let region = CLCircularRegion(center: geofence.center, radius: geofence.radius, identifier: geofence.sUUID)
		// TODO Allow user to set notify rules
		region.notifyOnEntry = true
		region.notifyOnExit = false
		return region
	}
    
    func checkAddMetroGeofences(){
        
        if !UserDefaults.standard.bool(forKey: "HasSetupMetroGeofences") {
            
            print("Setting up metro geofences")
            UserDefaults.standard.set(true, forKey: "HasSetupMetroGeofences")
            addMetroGeofences()
            
        }
    }
    
    func addMetroGeofences() {
        
        // Add predetermined Metro Geofences
		// TODO Handle if we are unable to add these geofences
        
        let radius: CLLocationDistance = 500;
        
        // T-Centralen
        let tCentralenId = "9001"
        let tCentralenCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.325665364, 18.056499774)
        let tCentralen = MetroGeofence(name: "T-Centralen", center: tCentralenCenter, radius: radius, stationId: tCentralenId)
		addGeofence(geofence: tCentralen, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        //Odenplan
        let odenplanId = "9117"
        let odenplanCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.338998644, 18.042666496)
        let odenplan = MetroGeofence(name: "Odenplan", center: odenplanCenter, radius: radius, stationId: odenplanId)
		addGeofence(geofence: odenplan, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        //Ropsten
        let ropstenId = "9220"
        let ropstenCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.354331916, 18.100999596)
        let ropsten = MetroGeofence(name: "Ropsten", center: ropstenCenter, radius: radius, stationId: ropstenId)
		addGeofence(geofence: ropsten, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        //Kista
        let kistaId = "9302"
        let KistaCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.40166506, 17.938496246)
        let kista = MetroGeofence(name: "Kista", center: KistaCenter, radius: radius, stationId: kistaId)
		addGeofence(geofence: kista, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        //Fridhemsplan
        let fridhemsplanId = "9115"
        let fridhemsplanCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.326165362, 18.0249999)
        let fridhemsplan = MetroGeofence(name: "Fridhemsplan", center: fridhemsplanCenter, radius: radius, stationId: fridhemsplanId)
		addGeofence(geofence: fridhemsplan, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
    }
	
	func displayNotificationForGeofence(geofence: Geofence) {
		
		let notificationService = (UIApplication.shared.delegate as! AppDelegate).notificationService
		
		var body = ""
		switch (geofence) {
		case is CalendarEventGeofence:
			let calendarEventGeofence = geofence as! CalendarEventGeofence
			displayCalendarEventNotification(notificationService: notificationService, geofenceName: calendarEventGeofence.name, calendarId: calendarEventGeofence.calendarId)
            return
		case is CustomGeofence:
			let customGeofence = geofence as! CustomGeofence
			body = customGeofence.customNotification
		case is MetroGeofence:
			let metroGeofence = geofence as! MetroGeofence
			displayMetroNotification(notificationService: notificationService, geofenceName: metroGeofence.name, stationId: metroGeofence.stationId)
            return
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
    
    func displayMetroNotification(notificationService: NotificationService, geofenceName: String, stationId: String) {
        
        let title = "Geofence: \(geofenceName)"
        var subTitle = ""
        var body = ""
        
        SLDepartureService.getSLDepartures(stationCode: stationId) { departures in
            
            if departures.count > 0 {
                
                for departure in departures {
                    
                    if subTitle == "" {
                        subTitle += "Station: \(departure.station)"
                    }
                    
                    body += departure.destination
                    body += " - \(departure.displayTime) "
                    body += "\n"
                }
                
                notificationService.showLocalNotification(
                    title: title,
                    subTitle: subTitle,
                    body: body
                )
            }
        }
    }
    
    func displayCalendarEventNotification(notificationService: NotificationService, geofenceName: String, calendarId: String) {
        
        let title = "Geofence: \(geofenceName)"
        var subTitle = ""
        var body = ""
        
        let events = CalendarEventService.getNextCalendarEvents(calendarEventId: calendarId)
        
        if events.count > 0 {
            
            for event in events {
                
                if subTitle == "" {
                    subTitle += "Calendar: \(calendarId)"
                }
                
                body += "Title: \(event.title)\n"
                body += "Location: \(event.location)\n"
                body += "Time: \(event.dateTime)\n"
                body += "\n"
            }
            
            notificationService.showLocalNotification(
                title: title,
                subTitle: subTitle,
                body: body
            )
        }
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
            checkAddMetroGeofences()
		case CLAuthorizationStatus.authorizedWhenInUse:
			locationStatus = "Authorized when in use"
            checkAddMetroGeofences()
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
		if let pendingGeofenceCompletionHandler = pendingLocationManagerRequests[region.identifier] {
			pendingGeofenceCompletionHandler(true, "Started monitoring geofence with ID \(region.identifier)")
		}
		pendingLocationManagerRequests.removeValue(forKey: region.identifier)
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("CLLocationManager.monitoringDidFailForRegion: \(String(describing: region)) with error: \(error)")
		if let region = region {
			if let pendingGeofenceCompletionHandler = pendingLocationManagerRequests[region.identifier] {
				pendingGeofenceCompletionHandler(false, "Error: \(error)")
			}
			pendingLocationManagerRequests.removeValue(forKey: region.identifier)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("CLLocationManager.didFailWithError: \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		
		print("CLLocationManager.didEnterRegion: \(region)")
        
        if let data = UserDefaults.standard.object(forKey: "geofenceDict") as? NSData {
            var geofenceDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [String: Geofence]
            
            if let geofence = geofenceDict[region.identifier] {
                print("CLLocationManager.didEnterRegion: Just entered geofence: \(geofence)")
                displayNotificationForGeofence(geofence: geofence)
            }
            else {
                print("CLLocationManager.didEnterRegion: Could not find geofence for region: \(region)")
            }
        }
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("CLLocationManager.didExitRegion: \(region)")
	}
}

