//
//  CreateGeofenceController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 21/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CreateGeofenceController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	let locationManager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Location manager setup
		self.locationManager.requestAlwaysAuthorization()
		if (CLLocationManager.locationServicesEnabled()) {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
		}
		
		// Map view setup
		mapView.delegate = self
		mapView.showsUserLocation = true
		let btnUserTracking = MKUserTrackingBarButtonItem(mapView: mapView)
		self.navigationItem.setRightBarButton(btnUserTracking, animated: false)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension CreateGeofenceController: CLLocationManagerDelegate {
	
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
			print("CLLocationManager.didUpdateLocations: \(latestLocation)")
		}
		else {
			print("CLLocationManager.didUpdateLocations: nil")
		}
	}
}

extension CreateGeofenceController: MKMapViewDelegate {
	
	// We use the mapview delegate to update the map
	// It only updates the user's location when he moves, not continuously
	// We could do it with the CLLocationManager, but the MKMapViewDelegate is easier
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		print("MKMapViewDelegate - user location updated: \(userLocation)")
		mapView.setCenter(userLocation.coordinate, animated: true)
	}
	
}
