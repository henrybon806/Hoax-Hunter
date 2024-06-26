//
//  ProfileInfo.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/8/24.
//

import SwiftUI

struct ProfileInfo: View {
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        VStack {
            Text("View Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("HoaxHunter")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Image("world")
                .resizable()
                .frame(width: 100,height: 100)
            
            Text("This is the profile page where you can manage things that have to do with your account. The profile page represents a user profile screen with features such as displaying and editing profile information, managing notification preferences, handling account actions like changing email and password, and showcasing saved reports. It integrates account authentication, storage, and Firestore database operations to fetch and update user data.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        
        Button(action: {
            isSheetPresented.toggle()
        }) {
            Text("Done")
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
}
