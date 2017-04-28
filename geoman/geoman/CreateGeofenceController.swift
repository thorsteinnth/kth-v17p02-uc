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
	// TODO Move location manager to AppDelegate or special class/service
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
		
		// UIBarButtonItems
		// User tracking button
		let btnUserTracking = MKUserTrackingBarButtonItem(mapView: mapView)
		// Add buttons to nav bar
		var navItemUIBarButtonItems = [UIBarButtonItem]()
		navItemUIBarButtonItems.append(btnUserTracking)
		self.navigationItem.setRightBarButtonItems(navItemUIBarButtonItems, animated: false)
		
		let longpressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onMapLongPress(sender:)))
		mapView.addGestureRecognizer(longpressRecognizer)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func drawCircleOnMap(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		let mapCircle = MapCircle(center: center, radius: radius)
		mapCircle.color = UIColor.blue
		mapView.add(mapCircle)
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		// This gets called when we add an overlay to the MKMapView
		if overlay is MapCircle {
			let circleRenderer = MKCircleRenderer(overlay: overlay)
			circleRenderer.strokeColor = (overlay as! MapCircle).color
			circleRenderer.fillColor = circleRenderer.strokeColor!.withAlphaComponent(0.1)
			circleRenderer.lineWidth = 1
			return circleRenderer
		}
		
		// Unknown overlay type, return empty overlay renderer (can't return nil)
		return MKOverlayRenderer()
	}
	
	func onMapLongPress(sender: UILongPressGestureRecognizer) {
		// Adapted from: https://stackoverflow.com/questions/14580269/get-tapped-coordinates-with-iphone-mapkit
		
		if sender.state != UIGestureRecognizerState.ended {
			return
		}
		
		let touchLocation = sender.location(in: mapView)
		let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
		
		// Show add geofence alert
		let alert = UIAlertController(
			title: "Add geofence",
			message: "Do you want to add a geofence here?",
			preferredStyle: UIAlertControllerStyle.alert
		)
		alert.addAction(UIAlertAction(
			title: "Yes",
			style: UIAlertActionStyle.default,
			handler: {(alert: UIAlertAction!) in self.createGeofence(center: locationCoordinate)})
		)
		alert.addAction(UIAlertAction(
			title: "Cancel",
			style: UIAlertActionStyle.cancel,
			handler: nil)
		)
		self.present(alert, animated: true, completion: nil)
	}
	
	func createGeofence(center: CLLocationCoordinate2D) {
		// TODO Get radius from user
		// TODO Save geofence to persistent storage (and actually create a geofence object)
		let radius: CLLocationDistance = 1000;
		print("Creating geofence at \(center) with radius \(radius)")
		drawCircleOnMap(center: center, radius: radius)
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
			//print("CLLocationManager.didUpdateLocations: \(latestLocation)")
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
