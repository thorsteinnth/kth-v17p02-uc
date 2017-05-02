//
//  CreateGeofenceController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CreateGeofenceController : UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	
	let geofenceService = (UIApplication.shared.delegate as! AppDelegate).geofenceService
	var center: CLLocationCoordinate2D?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Close button
		let btnClose = UIBarButtonItem(
			title: "Close",
			style: .plain,
			target: self,
			action: #selector(onCloseBarButtonItemPressed(sender:))
		)
		self.navigationItem.setLeftBarButton(btnClose, animated: false)
		
		// Create geofence button
		let btnCreateGeofence = UIBarButtonItem(
			title: "Create",
			style: .plain,
			target: self,
			action: #selector(onCreateGeofenceBarButtonItemPressed(sender:))
		)
		self.navigationItem.setRightBarButton(btnCreateGeofence, animated: false)
		
		// MKMapView
		mapView.delegate = self
		
		// Add pin annotation to the center of the geofence we want to create
		if let center = center {
			let mapPin = MapPin(title: "", subtitle: "", coordinate: center)
			mapView.addAnnotation(mapPin)
			centerAndZoomMapToCoordinate(coordinate: center)
		} else {
			print("CreateGeofenceController.viewDidLoad: ERROR - Do not have a center value")
		}
	}
	
	func onCloseBarButtonItemPressed(sender: Any) {
		self.dismiss(animated: true, completion: {});
	}
	
	func onCreateGeofenceBarButtonItemPressed(sender: Any) {
		// TODO Get radius from user
		// TODO Create geofence of the correct type
		if let center = center {
			let radius: CLLocationDistance = 1000;
			print("Creating geofence at \(center) with radius \(radius)")
			let geofence = CalendarEventGeofence(name: "test geofence", center: center, radius: radius, calendarId: "KTH")
			geofenceService.addGeofence(geofence: geofence)
			
			// Dismiss controller and go back
			self.dismiss(animated: true, completion: {});
		}
		else {
			print("CreateGeofenceController.onBtnCreateGeofencePressed: ERROR - Do not have a center value")
		}
	}
	
	func centerAndZoomMapToCoordinate(coordinate: CLLocationCoordinate2D) {
		let regionRadius: CLLocationDistance = 1000
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
		mapView.setRegion(coordinateRegion, animated: true)
	}
}

extension CreateGeofenceController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
	
		if let annotation = annotation as? MapPin {
			
			let identifier = "pin"
			var view: MKPinAnnotationView
			
			if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
				dequeuedView.annotation = annotation
				view = dequeuedView
			} else {
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				
				// Not using the callouts ... leaving it here for the future though
				//view.canShowCallout = true
				//view.calloutOffset = CGPoint(x: -5, y: 5)
				//view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
			}
			return view
		}
		return nil
	}
}

