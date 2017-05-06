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
	@IBOutlet weak var segctrlGeofenceType: UISegmentedControl!
	@IBOutlet weak var lblGeofenceTypeInstructions: UILabel!
	@IBOutlet weak var twCustomNotification: UITextView!	// TODO Fix typo
	@IBOutlet weak var tableViewCalendars: UITableView!
	
	enum GeofenceType: String {
		case calendar, custom
	}
	
	let geofenceService = (UIApplication.shared.delegate as! AppDelegate).geofenceService
	let calendarNames: [String] = CalendarEventService.getCalendarTitles()
	let tableViewCellReuseIdentifier = "cell"
	let initialRadius: CLLocationDistance = 500
	let sliderStep: Float = 100
	var center: CLLocationCoordinate2D?
	var selectedGeofenceType : GeofenceType = GeofenceType.calendar
	var selectedCalendarName: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		
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
			let mapPin = MapPin(title: "", subtitle: "", coordinate: center, geofenceId: "")
			mapView.addAnnotation(mapPin)
		} else {
			print("CreateGeofenceController.viewDidLoad: ERROR - Do not have a center value")
		}
		
		// Radius slider
		// Making this continuous, looks nicer, but mapview redraws are inefficient.
		sliderRadius.isContinuous = true
		sliderRadius.maximumValue = 1000
		sliderRadius.minimumValue = 100
		sliderRadius.value = Float(initialRadius)
		
		// Radius label
		lblRadius.text = getRadiusString(radius: Int(sliderRadius.value))
		
		updateMapView()
		
		// Geofence type segmented control
		segctrlGeofenceType.setTitle("Calendar", forSegmentAt: 0)
		segctrlGeofenceType.setTitle("Custom", forSegmentAt: 1)
		onGeofenceTypeCalendarSelected()	// Calendar is the default selection
		
		// Custom notification text view
		twCustomNotification.text = ""
		twCustomNotification.layer.borderWidth = 1
		twCustomNotification.layer.cornerRadius = 5
		twCustomNotification.layer.borderColor = UIColor.lightGray.cgColor
		
		// Calendar table view
		tableViewCalendars.register(UITableViewCell.self, forCellReuseIdentifier: tableViewCellReuseIdentifier)
		tableViewCalendars.delegate = self
		tableViewCalendars.dataSource = self
		tableViewCalendars.layer.borderWidth = 1
		tableViewCalendars.layer.cornerRadius = 5
		tableViewCalendars.layer.borderColor = UIColor.lightGray.cgColor
		
		// Keyboard handling
		// Adapted from: http://stackoverflow.com/a/31124676
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	func getRadiusString(radius: Int) -> String {
		return "Radius: \(radius) m"
	}
	
	func onCloseBarButtonItemPressed(sender: Any) {
		self.dismiss(animated: true, completion: {});
	}
	
	func onCreateGeofenceBarButtonItemPressed(sender: Any) {
		
		// Verify that the user has selected a calendar
		if selectedGeofenceType == GeofenceType.calendar && selectedCalendarName == "" {
			// Show alert asking user to select a calendar
			let alert = UIAlertController(
				title: "Please select calendar",
				message: "Please select what calendar events you want to see for this geofence",
				preferredStyle: UIAlertControllerStyle.alert
			)
			alert.addAction(UIAlertAction(
				title: "OK",
				style: UIAlertActionStyle.default,
				handler: nil)
			)
			self.present(alert, animated: true, completion: nil)
			return
		}
		
		// Add the geofence
		if let center = center {
			let radius: CLLocationDistance = CLLocationDistance(Int(sliderRadius.value));
			
			if (selectedGeofenceType == GeofenceType.calendar) {
				let geofence = CalendarEventGeofence(center: center, radius: radius, calendarId: selectedCalendarName)
				print("Creating \(selectedGeofenceType) geofence at \(center) with radius \(radius) and calendar name \(selectedCalendarName)")
				geofenceService.addGeofence(geofence: geofence, onCompletion: {(success: Bool, message: String) -> Void in
					if success {
						self.onCreateGeofenceSuccess()
					} else {
						self.onCreateGeofenceFailure()
					}
				})
			}
			else if (selectedGeofenceType == GeofenceType.custom) {
				var finalNotificationText: String = ""
				if let notificationTextInput = twCustomNotification.text {
					finalNotificationText = notificationTextInput
				}
				let geofence = CustomGeofence(center: center, radius: radius, customNotification: finalNotificationText)
				print("Creating \(selectedGeofenceType) geofence at \(center) with radius \(radius) and custom notification text \(finalNotificationText)")
				geofenceService.addGeofence(geofence: geofence, onCompletion: {(success: Bool, message: String) -> Void in
					if success {
						self.onCreateGeofenceSuccess()
					} else {
						self.onCreateGeofenceFailure()
					}
				})
			}
			else {
				print("Could not create geofence: Unknown geofence type")
			}
		}
		else {
			print("CreateGeofenceController.onBtnCreateGeofencePressed: ERROR - Do not have a center value")
		}
	}
	
	func onCreateGeofenceSuccess() {
		// Dismiss controller and go back
		self.dismiss(animated: true, completion: {});
	}
	
	func onCreateGeofenceFailure() {
		// Show error message
		let alert = UIAlertController(
			title: "Error",
			message: "Could not add geofence",
			preferredStyle: UIAlertControllerStyle.alert
		)
		alert.addAction(UIAlertAction(
			title: "OK",
			style: UIAlertActionStyle.default,
			handler: nil)
		)
		self.present(alert, animated: true, completion: nil)
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
		//let roundedValue = round(sender.value / sliderStep) * sliderStep
		lblRadius.text = getRadiusString(radius: Int(sender.value))
		updateMapView()
	}
	
	// Geofence type selection
	
	@IBAction func onGeofenceTypeChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			onGeofenceTypeCalendarSelected()
		case 1:
			onGeofenceTypeCustomSelected()
		default:
			print("Unknown geofence type selected")
		}
	}
	
	func onGeofenceTypeCalendarSelected() {
		selectedGeofenceType = GeofenceType.calendar
		tableViewCalendars.isHidden = false;
		twCustomNotification.isHidden = true;
		updateGeofenceTypeInstructions()
	}
	
	func onGeofenceTypeCustomSelected() {
		selectedGeofenceType = GeofenceType.custom
		tableViewCalendars.isHidden = true
		twCustomNotification.isHidden = false
		updateGeofenceTypeInstructions()
	}
	
	func updateGeofenceTypeInstructions() {
		switch selectedGeofenceType {
		case GeofenceType.calendar:
			lblGeofenceTypeInstructions.text = "Select calendar event source"
		case GeofenceType.custom:
			lblGeofenceTypeInstructions.text = "Create custom notification"
		}
	}
	
	// Geofence overlay
	
	func redrawGeofenceCircleOnMap(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
		// NOTE: This gets called very often since we are using a continuous slider.
		// Probably very inefficient, but keeping it as is since it looks nicer.
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
	
	// Keyboard handling
	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0 {
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y != 0 {
				self.view.frame.origin.y += keyboardSize.height
			}
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

extension CreateGeofenceController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return calendarNames.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell = tableViewCalendars.dequeueReusableCell(withIdentifier: tableViewCellReuseIdentifier) as UITableViewCell!
		cell.textLabel?.text = calendarNames[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCalendarName = calendarNames[indexPath.row]
	}
}

