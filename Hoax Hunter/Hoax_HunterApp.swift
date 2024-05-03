//
//  Hoax_HunterApp.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/8/23.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        application.registerForRemoteNotifications()
        print(application.isRegisteredForRemoteNotifications)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        Messaging.messaging().appDidReceiveMessage(userInfo)

        print(userInfo)

        return [[.sound]]
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo

        Messaging.messaging().appDidReceiveMessage(userInfo)

        print(userInfo)
      }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
       Messaging.messaging().appDidReceiveMessage(userInfo)

      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      print(userInfo)

      return UIBackgroundFetchResult.newData
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print(deviceToken.base64EncodedString())
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print(error)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("fcm", fcm)
            UserDefaults.standard.set(fcm, forKey: "fcm")
        }
    }
}

@main
struct Hoax_HunterApp: App {
    @AppStorage("hasShownSheet", store: .standard) var hasShownSheet = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Login(hasShownSheet: $hasShownSheet)
                .preferredColorScheme(.light)
        }
    }
}

struct StartView: View {
    @Binding var hasShownSheet: Bool
    @State var isSheetPresented = false
    @State private var fcmTokenMessage: String = ""
    @State private var remoteFCMTokenMessage: String = ""
    @MainActor let notifications = Notifications()
    
    var body: some View {
        VStack{
            DetectorNews()
        }
        .onAppear {
            Task {
                await notifications.request() // Call a method from Notifications
            }
            
            if !(hasShownSheet) {
                isSheetPresented = true
                hasShownSheet = true
                UserDefaults.standard.set(true, forKey: "hasShownSheet")
            }
        }
        .sheet(isPresented: ($isSheetPresented)){
            WelcomeView(isSheetPresented: $isSheetPresented)
        }
    }
}
