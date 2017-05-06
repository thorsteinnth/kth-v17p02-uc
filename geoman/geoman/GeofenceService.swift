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
		let region = convertGeofenceToCircularRegion(geofence: geofence)
		locationManager.startMonitoring(for: region)
	}
	
	func removeGeofence(geofence: Geofence, onCompletion: AsyncCompletionHandler) {
		// NOTE: There is no callback for the stopMonitoringForRegion method
		let region = convertGeofenceToCircularRegion(geofence: geofence)
		locationManager.stopMonitoring(for: region)
		let regionIsMonitored: Bool = locationManager.monitoredRegions.contains(region)
		if !regionIsMonitored {
			print("Stopped monitoring geofence: \(geofence) --- Number of monitored regions: \(locationManager.monitoredRegions.count)")
			deleteGeofence(geofence: geofence)
			onCompletion(true, "")
		}
		else {
			print("Error: Region for geofence still monitored: \(geofence)")
			onCompletion(false, "")
		}
	}
	
	func saveGeofence(geofence: Geofence) {
		// Add/update geofence to/in our local set of geofences
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
	
	func deleteGeofence(geofence: Geofence) {
		// Delete geofence from our local set of geofences
		if let data = UserDefaults.standard.object(forKey: "geofenceDict") as? NSData {
			var geofenceDict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [String: Geofence]
			geofenceDict.removeValue(forKey: geofence.sUUID)
			let data = NSKeyedArchiver.archivedData(withRootObject: geofenceDict)
			UserDefaults.standard.set(data, forKey: "geofenceDict")
		}
		
		print("Deleted geofence: \(geofence)")
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
	
	func getGeofenceWithId(id: String) -> Geofence? {
		let geofences = getAllGeofences()
		for geofence in geofences {
			if geofence.sUUID == id {
				return geofence
			}
		}
		return nil
	}
	
	func convertGeofenceToCircularRegion(geofence: Geofence) -> CLCircularRegion {
		let region = CLCircularRegion(center: geofence.center, radius: geofence.radius, identifier: geofence.sUUID)
		// We just have notify on entry
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
		
		// TODO Get station IDs from SL Platsuppslag API
		// TODO Handle if we are unable to add these geofences
		// GPS coord source: https://www.gps-coordinates.net/
		// Station ID source: https://www.trafiklab.se/api/sl-platsuppslag/sl-platsuppslag-dokumentation
		
		/*
		Station IDs and lat-long
		T-Centralen 9001 59.3306315,18.059330000000045
		Odenplan 9117 59.34294790000001,18.049898999999982
		Ropsten 9220 59.3572983,18.102217900000028
		Kista 9302 59.4031774,17.942394400000012
		Fridhemsplan 9115 59.33219949999999,18.029187800000045
		Slussen 9192 59.31951240000001,18.07214060000001
		Radhuset 9309 59.33033229999999,18.042047700000012
		Tekniska Högskolan 9204 59.3459088,18.071596399999976
		Gamla Stan 9193 59.323108163701576,18.067381381988525
		Gullmarsplan 9189 59.2990447,18.080944899999963
		Stadshagen 9307 59.3382823,18.013847499999997
		Liljeholmen 9294 59.3101636,18.02225909999993
		*/
		
        let radius: CLLocationDistance = 200;
        
        // T-Centralen 9001 59.3306315,18.059330000000045
        let tCentralenId = "9001"
        let tCentralenCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.3306315,18.059330000000045)
		let tCentralen = MetroGeofence(center: tCentralenCenter, radius: radius, stationId: tCentralenId, name: "T-Centralen")
		addGeofence(geofence: tCentralen, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        // Odenplan 9117 59.34294790000001,18.049898999999982
        let odenplanId = "9117"
        let odenplanCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.34294790000001,18.049898999999982)
        let odenplan = MetroGeofence(center: odenplanCenter, radius: radius, stationId: odenplanId, name: "Odenplan")
		addGeofence(geofence: odenplan, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        // Ropsten 9220 59.3572983,18.102217900000028
        let ropstenId = "9220"
        let ropstenCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.3572983,18.102217900000028)
        let ropsten = MetroGeofence(center: ropstenCenter, radius: radius, stationId: ropstenId, name: "Ropsten")
		addGeofence(geofence: ropsten, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        // Kista 9302 59.4031774,17.942394400000012
        let kistaId = "9302"
        let KistaCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.4031774,17.942394400000012)
        let kista = MetroGeofence(center: KistaCenter, radius: radius, stationId: kistaId, name: "Kista")
		addGeofence(geofence: kista, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		// Slussen 9192 59.31951240000001,18.07214060000001
		let slussen = MetroGeofence(center: CLLocationCoordinate2DMake(59.31951240000001,18.07214060000001), radius: radius, stationId: "9192", name: "Slussen")
		addGeofence(geofence: slussen, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		// Radhuset 9309 59.33033229999999,18.042047700000012
		let radhuset = MetroGeofence(center: CLLocationCoordinate2DMake(59.33033229999999,18.042047700000012), radius: radius, stationId: "9309", name: "Rådhuset")
		addGeofence(geofence: radhuset, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		// Tekniska Högskolan 9204 59.3459088,18.071596399999976
		let tekniskahogskolan = MetroGeofence(center: CLLocationCoordinate2DMake(59.3459088,18.071596399999976), radius: radius, stationId: "9204", name: "Tekniska Högskolan")
		addGeofence(geofence: tekniskahogskolan, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		// Gamla Stan 9193 59.323108163701576,18.067381381988525
		let gamlastan = MetroGeofence(center: CLLocationCoordinate2DMake(59.323108163701576,18.067381381988525), radius: radius, stationId: "9193", name: "Gamla Stan")
		addGeofence(geofence: gamlastan, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		// Gullmarsplan 9189 59.2990447,18.080944899999963
		let gullmarsplan = MetroGeofence(center: CLLocationCoordinate2DMake(59.2990447,18.080944899999963), radius: radius, stationId: "9189", name: "Gullmarsplan")
		addGeofence(geofence: gullmarsplan, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		// Stadshagen 9307 59.3382823,18.013847499999997
		let stadshagen = MetroGeofence(center: CLLocationCoordinate2DMake(59.3382823,18.013847499999997), radius: radius, stationId: "9307", name: "Stadshagen")
		addGeofence(geofence: stadshagen, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
		//Liljeholmen 9294 59.3101636,18.02225909999993
		let liljeholmen = MetroGeofence(center: CLLocationCoordinate2DMake(59.3101636,18.02225909999993), radius: radius, stationId: "9294", name: "Liljeholmen")
		addGeofence(geofence: liljeholmen, onCompletion: {(success: Bool, message: String) -> Void in
			// Do nothing
		})
		
        // Fridhemsplan 9115 59.33219949999999,18.029187800000045
        let fridhemsplanId = "9115"
        let fridhemsplanCenter: CLLocationCoordinate2D = CLLocationCoordinate2DMake(59.33219949999999,18.029187800000045)
        let fridhemsplan = MetroGeofence(center: fridhemsplanCenter, radius: radius, stationId: fridhemsplanId, name: "Fridhemsplan")
		addGeofence(geofence: fridhemsplan, onCompletion: {(success: Bool, message: String) -> Void in
			// This is the last hardcoded geofence we add
			// We assume that it will be added last, i.e. that they are added sequentially
			self.initialGeofencesAdded()
		})
    }
	
	func initialGeofencesAdded() {
		// Let AppDelegate know that the initial geofences have been added
		(UIApplication.shared.delegate as! AppDelegate).initialGeofencesAdded()
	}
	
	func displayNotificationForGeofence(geofence: Geofence) {
		
		let notificationService = (UIApplication.shared.delegate as! AppDelegate).notificationService
		
		switch (geofence) {
		case is CalendarEventGeofence:
			let calendarEventGeofence = geofence as! CalendarEventGeofence
			displayCalendarEventNotification(notificationService: notificationService, calendarId: calendarEventGeofence.calendarId)
            return
		case is CustomGeofence:
			let customGeofence = geofence as! CustomGeofence
			displayCustomNotification(notificationService: notificationService, notificationText: customGeofence.customNotification)
			return
		case is MetroGeofence:
			let metroGeofence = geofence as! MetroGeofence
			if (metroGeofence.showNotifications) {
				displayMetroNotification(notificationService: notificationService, geofenceName: metroGeofence.name, stationId: metroGeofence.stationId)
			}
			else{
				print("Not showing notification for metro station geofence \(metroGeofence.name)")
			}
            return
		default:
			print("GeofenceService.displayNotificationForGeofence - Unknown geofence type: \(type(of: geofence))")
		}
	}
	
	func displayCustomNotification(notificationService: NotificationService, notificationText: String) {
		notificationService.showLocalNotification(
			title: "Custom notification",
			subTitle: "",
			body: notificationText
		)
	}
    
    func displayMetroNotification(notificationService: NotificationService, geofenceName: String, stationId: String) {
        
        let title = "Metro station: \(geofenceName)"
        let subTitle = ""
        var body = ""
        
        SLDepartureService.getSLDepartures(stationCode: stationId) { departures in
            
            if departures.count > 0 {
				
				var departureCount: Int = 0
                for departure in departures {
					
					// Departure should always be the geofence station
                    //if subTitle == "" {
                    //    subTitle += "Station: \(departure.station)"
                    //}
                    
                    body += "T\(departure.lineNumber)"
					body += " - \(departure.destination)"
                    body += " - \(departure.displayTime)"
                    body += "\n"
					
					// Let's only show the next 6 departures
					if departureCount >= 5 {
						break
					}
					
					departureCount = departureCount + 1
                }
			
                notificationService.showLocalNotification(
                    title: title,
                    subTitle: subTitle,
                    body: body
                )
            }
        }
    }
    
    func displayCalendarEventNotification(notificationService: NotificationService, calendarId: String) {
        
        let title = "Calendar: \(calendarId)"
        let subTitle = ""
        var body = ""
        
        let events = CalendarEventService.getNextCalendarEvents(calendarEventId: calendarId)
        
        if events.count > 0 {
            
            for event in events {
                
                if subTitle == "" {
                    //subTitle += "Calendar: \(calendarId)"
                }
                
                body += "Title: \(event.title)\n"
				if (event.location != "") {
                	body += "Location: \(event.location)\n"
				}
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
		print("CLLocationManager.didStartMonitoringForRegion: \(region) --- Number of monitored regions: \(locationManager.monitoredRegions.count)")
		if let pendingGeofenceCompletionHandler = pendingLocationManagerRequests[region.identifier] {
			pendingGeofenceCompletionHandler(true, "Started monitoring geofence with ID \(region.identifier)")
		}
		pendingLocationManagerRequests.removeValue(forKey: region.identifier)
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("CLLocationManager.monitoringDidFailForRegion: \(String(describing: region)) with error: \(error) --- Number of monitored regions: \(locationManager.monitoredRegions.count)")
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

