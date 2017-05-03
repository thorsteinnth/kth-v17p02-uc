//
//  MapViewController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 21/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	let geofenceService = (UIApplication.shared.delegate as! AppDelegate).geofenceService
	
	// Stores the coordinates of the geofence we are about to create
	// Stored as an instance variable so we can use it in the prepareForSegue() method
	var newGeofenceCenter: CLLocationCoordinate2D?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		refreshGeofenceOverlays()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshGeofenceOverlays() {
		// Remove all existing overlays from the map
		let overlays = mapView.overlays
		mapView.removeOverlays(overlays)
		// Redraw all existing geofences
		let geofences = geofenceService.getAllGeofences()
		for geofence in geofences {
			drawGeofenceOnMap(geofence: geofence)
		}
	}
	
	func drawGeofenceOnMap(geofence: Geofence) {
		// Geofences are circles
		let mapCircle = MapCircle(center: geofence.center, radius: geofence.radius)
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
		newGeofenceCenter = center
		self.performSegue(withIdentifier: "CreateGeofencePresentModallySegue", sender:self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationViewController = segue.destination as? UINavigationController {
			if let createGeofenceController = destinationViewController.topViewController as? CreateGeofenceController {
				createGeofenceController.center = newGeofenceCenter
			}
		}
	}	
}

extension MapViewController: MKMapViewDelegate {
	
	// We use the mapview delegate to update the map
	// It only updates the user's location when he moves, not continuously
	// We could do it with the CLLocationManager, but the MKMapViewDelegate is easier
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		//print("MKMapViewDelegate - user location updated: \(userLocation)")
		mapView.setCenter(userLocation.coordinate, animated: true)
	}
	
}
