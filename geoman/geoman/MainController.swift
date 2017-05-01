//
//  MainController.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 21/04/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import UIKit
import EventKit
import UserNotifications
import UserNotificationsUI

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
        
        // Testing Calendar
        //getCalendarEvents()
        
        // Testing getting departures from Trafiklab - SL API
        //getNextSLDepartures()
        
        //showSimpleLocalNototification()
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
    
    func getCalendarEvents() {
        
        let eventStore = EKEventStore()
        
        let authorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        if authorizationStatus == EKAuthorizationStatus.authorized {
            
            let calendars = eventStore.calendars(for: EKEntityType.event)
            
            for calendar in calendars {
                
                if calendar.title == "KTH" {
                    
                    // Find events for the next 4 hours
                    let startDate = Date(timeIntervalSinceNow: 0)
                    let endDate = Date(timeIntervalSinceNow: 24*3600)
                    
                    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                    
                    let events = eventStore.events(matching: predicate)
                    
                    for event in events {
                        
                        print("Class: " + event.title)
                        print("Room: " + event.location!)
                        
                        let time = DateFormatter.localizedString(from: event.startDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
                        
                        print("Date and time: " + time)
                    }
                }
            }
        }
    }
    
    //TEST Code for Local Notification
    
    func showSimpleLocalNototification() {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Test Notifications"
        notificationContent.subtitle = "Some subtitle"
        notificationContent.body = "Test local notification"
        notificationContent.sound = UNNotificationSound.default()
        
        //trigger after 10 sec
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 10.0, repeats: false)
        let req = UNNotificationRequest(identifier: "someId", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(req){(error) in
            
            if (error != nil){
                
                print("error")
            }
        }
        
    }
}

extension MainController : UNUserNotificationCenterDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        
        if notification.request.identifier == "someId"{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

