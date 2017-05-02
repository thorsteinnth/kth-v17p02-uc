//
//  CreateGeofenceController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit
import CoreLocation

class CreateGeofenceController : UIViewController {

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
}
