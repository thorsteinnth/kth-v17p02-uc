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
	
	// TODO Update mapview as the hardcoded geofences are added for the first time
	
	// Stores the coordinates of the geofence we are about to create
	// Stored as an instance variable so we can use it in the prepareForSegue() method
	var newGeofenceCenter: CLLocationCoordinate2D?
	
	// Used to zoom to the users location when we get the first location measurement
	var initialZoomToLocationDone: Bool = false
	
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
		refreshGeofenceOverlaysAndAnnotations()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshGeofenceOverlaysAndAnnotations() {
		// Remove all existing overlays and annotations from the map
		let overlays = mapView.overlays
		mapView.removeOverlays(overlays)
		let annotations = mapView.annotations
		mapView.removeAnnotations(annotations)
		// Redraw all existing geofences
		let geofences = geofenceService.getAllGeofences()
		for geofence in geofences {
			drawGeofenceOnMap(geofence: geofence)
		}
	}
	
	func drawGeofenceOnMap(geofence: Geofence) {
		// Geofences are circles, add circle overlay
		let mapCircle = MapCircle(center: geofence.center, radius: geofence.radius)
		mapCircle.color = UIColor.blue
		mapView.add(mapCircle)
		// Add pin annotation in center of geofence
		var annotationTitle: String
		switch geofence {
		case is MetroGeofence:
			let metroGeofence = geofence as! MetroGeofence
			annotationTitle = metroGeofence.name
		case is CalendarEventGeofence:
			let calendarGeofence = geofence as! CalendarEventGeofence
			annotationTitle = "Calendar: \(calendarGeofence.calendarId)"
		case is CustomGeofence:
			annotationTitle = "Custom geofence"
		default:
			annotationTitle = ""
		}
		let mapPin = MapPin(title: annotationTitle, subtitle: "", coordinate: geofence.center, geofenceId: geofence.sUUID)
		mapView.addAnnotation(mapPin)
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
	
	// Show options for geofences
	
	func showOptionsForGeofence(geofenceId: String)
	{
		let geofence = geofenceService.getGeofenceWithId(id: geofenceId)
		if let geofence = geofence {
			if geofence is CustomGeofence || geofence is CalendarEventGeofence {
				showOptionsForUserCreatedGeofence(geofence: geofence)
			}
			else if geofence is MetroGeofence {
				showOptionsForMetroGeofence(geofence: geofence as! MetroGeofence)
			}
			else {
				print("Unkown geofence type - can't show options for it")
			}
		}
		else {
			print("Could not find geofence with ID: \(geofenceId)")
		}
	}
	
	func showOptionsForUserCreatedGeofence(geofence: Geofence) {
		// Show delete geofence alert
		let alert = UIAlertController(
			title: "Delete geofence",
			message: "Do you want to delete this geofence?",
			preferredStyle: UIAlertControllerStyle.alert
		)
		alert.addAction(UIAlertAction(
			title: "Yes",
			style: UIAlertActionStyle.default,
			handler: {(alert: UIAlertAction!) in self.deleteGeofence(geofence: geofence)})
		)
		alert.addAction(UIAlertAction(
			title: "Cancel",
			style: UIAlertActionStyle.cancel,
			handler: nil)
		)
		self.present(alert, animated: true, completion: nil)
	}
	
	func showOptionsForMetroGeofence(geofence: MetroGeofence) {
		// Show alert for turning notifications on or off
		var message: String = ""
		if geofence.showNotifications {
			message = "Do you want to turn off notifications for this geofence?"
		}
		else {
			message = "Do you want to turn on notifications for this geofence?"
		}
		
		let alert = UIAlertController(
			title: "Toggle notifications for geofence",
			message: message,
			preferredStyle: UIAlertControllerStyle.alert
		)
		alert.addAction(UIAlertAction(
			title: "Yes",
			style: UIAlertActionStyle.default,
			handler: {(alert: UIAlertAction!) in self.toggleNotificationsForMetroGeofence(geofence: geofence)})
		)
		alert.addAction(UIAlertAction(
			title: "Cancel",
			style: UIAlertActionStyle.cancel,
			handler: nil)
		)
		self.present(alert, animated: true, completion: nil)
	}
	
	// Create geofence
	
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
	
	// Edit geofences
	
	func deleteGeofence(geofence: Geofence) {
		// TODO
		print("Should delete geofence \(geofence)")
	}
	
	func toggleNotificationsForMetroGeofence(geofence: MetroGeofence) {
		// TODO
		if geofence.showNotifications {
			print("Should turn off notifications for geofence: \(geofence)")
		}
		else {
			print("Should turn on notifications for geofence: \(geofence)")
		}
	}
}

extension MapViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		//print("MKMapViewDelegate - user location updated: \(userLocation)")
		
		// Zoom to the user's location if this is the first location reading we get.
		if !initialZoomToLocationDone {
			// We show a radius of 2 km around the user
			let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
			mapView.setRegion(coordinateRegion, animated: true)
			initialZoomToLocationDone = true
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if let annotation = annotation as? MapPin {
			
			let identifier = "pin"
			var view: MKPinAnnotationView
			
			if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
				dequeuedView.annotation = annotation
				view = dequeuedView
			} else {
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView	// TODO Change button look?
			}
			
			return view
		}
		return nil
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if let annotation = view.annotation {
			if (annotation is MapPin) {
				let mapPin = annotation as! MapPin
				showOptionsForGeofence(geofenceId: mapPin.geofenceId)
			}
		}
	}
}
