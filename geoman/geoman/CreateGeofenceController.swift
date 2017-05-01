//
//  CreateGeofenceController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit

class CreateGeofenceController : UIViewController {

	@IBOutlet weak var btnCreateGeofence: UIButton!
	
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
		
		btnCreateGeofence.setTitle("Create geofence", for: UIControlState.normal)
	}
	
	func onCloseBarButtonItemPressed(sender: Any) {
		self.dismiss(animated: true, completion: {});
	}
	
	@IBAction func onBtnCreateGeofencePressed(_ sender: Any) {
		print("Should create geofence")
	}
	
}
