//
//  MainController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 21/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit

class MainController: UIViewController {
	
	@IBOutlet weak var btnCreateGeofence: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		btnCreateGeofence.setTitle("Create geofence :)", for: UIControlState.normal);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func onBtnCreateGeofencePressed(_ sender: Any) {
		print("test");
	}
    
    override func viewDidAppear(_ animated: Bool) {
        
        getNextSLDepartures()
        
    }
    
    func getNextSLDepartures() {
        
        // Talk to the SL API
        
        SLDeparture.getDepartures(station: "Kista") { departures in
            print("Here we should get the departures")
        }
    }
}

