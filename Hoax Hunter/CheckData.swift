//
//  CheckData.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/13/24.
//

import SwiftUI
import UIKit
import Firebase
import UserNotifications

struct CheckData {
    func checkData(){
        
    }

    func updateUser(){
        
    }
    
    private func sendPushNotification() {
        // Configure the notification content
        let content = UNMutableNotificationContent()
        content.title = "New Data Available"
        content.body = "There is new data available in the Firebase database."

        // Configure the notification trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create the notification request
        let request = UNNotificationRequest(identifier: "DataUpdateNotification", content: content, trigger: trigger)

        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully")
            }
        }
    }
}
