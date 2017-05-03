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
	
	func showLocalNotification(title: String, subTitle: String, body: String) {
		
		let notificationContent = UNMutableNotificationContent()
		notificationContent.title = title
		notificationContent.subtitle = subTitle
		notificationContent.body = body
		notificationContent.sound = UNNotificationSound.default()
		
		let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
		let req = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
		
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
		completionHandler( [.alert,.sound,.badge])
	}
}
