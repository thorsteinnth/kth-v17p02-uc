//
//  NotificationService.swift
//  geoman
//
//  Created by Þorsteinn Þorri Sigurðsson on 01/05/2017.
//  Copyright © 2017 ttsifannar. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI

class NotificationService: NSObject {
	
	// TODO Show proper notifications
	
	func showLocalNotification() {
		
		let notificationContent = UNMutableNotificationContent()
		notificationContent.title = "Test Notifications"
		notificationContent.subtitle = "Some subtitle"
		notificationContent.body = "Test local notification"
		notificationContent.sound = UNNotificationSound.default()
		
		// trigger after 10 sec
		let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 10.0, repeats: false)
		let req = UNNotificationRequest(identifier: "someId", content: notificationContent, trigger: trigger)
		
		UNUserNotificationCenter.current().delegate = self
		UNUserNotificationCenter.current().add(req){(error) in
			if (error != nil) {
				print("error")
			}
		}
	}
}

extension NotificationService : UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		print("Tapped in notification")
	}
	
	// This is key callback to present notification while the app is in foreground
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		print("Notification being triggered")
		
		if notification.request.identifier == "someId" {
			completionHandler( [.alert,.sound,.badge])
		}
	}
}
