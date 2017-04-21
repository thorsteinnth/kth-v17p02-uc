//
//  CreateGeofenceController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 21/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit

class CreateGeofenceController: UIViewController {
	
	@IBOutlet weak var lblCreateGeofence: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		lblCreateGeofence.text = "Should create geofence here";
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
