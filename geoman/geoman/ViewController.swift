//
//  ViewController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 21/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    override func viewDidAppear(_ animated: Bool) {
        
        // testing Calendar access..
        // TODO:
        // we could maybe have a settings screen where the user could manage his events,
        // like which calender he want's to give access to and at what locations he would like to receive the calendar alerts?
        getCalendarAccess()
        getCalendarEvents()
        
    }
    
    func getCalendarAccess(){
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if !accessGranted {
                let alertController = UIAlertController(title: "Warning", message: "You need to allow access to the calendar in order to receive event notifications.", preferredStyle: .alert);
                
                self.present(alertController, animated: true){}
            }
        })
    }
    
    func getCalendarEvents() {
        let eventStore = EKEventStore()
        
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        if authorizationStatus == EKAuthorizationStatus.authorized {
            
            let calendars = eventStore.calendars(for: EKEntityType.event)
            
            for calendar in calendars {
                
                // TODO : We could have a setting screen where the user selects which calender he want's to get notifications for
                print(calendar.title)
                if calendar.title == "Calendar" {
                    
                    let startDate = Date(timeIntervalSinceNow: 0)
                    let endDate = Date(timeIntervalSinceNow: 12*3600)
                    
                    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                    
                    let events = eventStore.events(matching: predicate)
                    
                    for event in events {
                        
                        print("Event found: " + event.title)
                    }
                }
            }
        }
    }
    
    
}

