//
//  Notifications.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/13/24.
//

import Foundation
import UserNotifications

@MainActor
class Notifications: ObservableObject{
    @Published private(set) var hasPermission = false
    
    init() {
        Task{
            await request()
            await getAuthStatus()
        }
    }
    
    func request() async{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
             await getAuthStatus()
        } catch{
            print(error)
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
}
