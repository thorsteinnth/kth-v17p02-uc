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
		btnCreateGeofence.setTitle("Create geofence", for: UIControlState.normal);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func onBtnCreateGeofencePressed(_ sender: Any) {
		print("test");
	}
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Testing getting departures from Trafiklab - SL API
        getNextSLDepartures()
        
    }
    
    func getNextSLDepartures() {
        
        // Talk to the SL API
        
        // T-Centralen: 9001
        // Odenplan: 9117
        // Ropsten: 9220
        // Kista: 9302
        
        SLDeparture.getDepartures(stationCode: "9302") { departures in
            
            if departures.count > 0 {
                print("We got departures:")
            }
            
            for departure in departures {
                
                print("Station: " + departure.station)
                print("Destination: " + departure.destination)
                print("Time: " + departure.displayTime)
                print("")
            }
        }
    }
}

