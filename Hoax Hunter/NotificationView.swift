//
//  NotificationView.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/16/24.
//

import SwiftUI

struct NotificationView: View {
    @StateObject var notificationManager = Notifications()
    var body: some View{
        VStack{
            Button("Request Notification"){
                Task{
                    await notificationManager.request()
                }
            }
            .buttonStyle(.bordered)
            .disabled(notificationManager.hasPermission)
            .task {
                await notificationManager.getAuthStatus()
            }
        }
        .onAppear(){
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }
}

#Preview {
    NotificationView()
}
