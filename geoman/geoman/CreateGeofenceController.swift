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
	@IBOutlet weak var lblRadius: UILabel!
	@IBOutlet weak var sliderRadius: UISlider!
	
	let geofenceService = (UIApplication.shared.delegate as! AppDelegate).geofenceService
	let initialRadius: CLLocationDistance = 500
	let sliderStep: Float = 100
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
		} else {
			print("CreateGeofenceController.viewDidLoad: ERROR - Do not have a center value")
		}
		
		// Radius slider
		sliderRadius.isContinuous = false
		sliderRadius.maximumValue = 1000
		sliderRadius.minimumValue = 100
		sliderRadius.value = Float(initialRadius)
		
		// Radius label
		lblRadius.text = getRadiusString(radius: sliderRadius.value)
		
		updateMapView()
	}
	
	func getRadiusString(radius: Float) -> String {
		return "Radius: \(radius) m"
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
	
	func centerAndZoomMapToCoordinate(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
		let minRadius: CLLocationDistance = 200
		var radiusToShow: CLLocationDistance = minRadius
		if (radius > minRadius) {
			radiusToShow = radius
		}
		// The length given in RegionMakeWithDistance is diameter. We show the radius we want to show plus a little extra.
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, radiusToShow * 2.3, radiusToShow * 2.3)
		mapView.setRegion(coordinateRegion, animated: true)
	}
	
	@IBAction func onRadiusSliderValueChanged(_ sender: UISlider) {
		// We want the slider to return values with preset increments
		let roundedValue = round(sender.value / sliderStep) * sliderStep
		lblRadius.text = getRadiusString(radius: roundedValue)
		updateMapView()
	}
	
	// Geofence overlay
	
	func redrawGeofenceCircleOnMap(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		// Remove current geofence circles, if any
		let currentOverlays = mapView.overlays
		mapView.removeOverlays(currentOverlays)
		// Geofences are circles, represented with the MapCircle object
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
	
	func updateMapView() {
		if let center = center {
			let radius: CLLocationDistance = CLLocationDistance(sliderRadius.value)
			redrawGeofenceCircleOnMap(center: center, radius: radius)
			centerAndZoomMapToCoordinate(coordinate: center, radius: radius)
		}
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

