//
//  Loading Screen.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/10/23.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        NavigationView{
            VStack {
                Text("Welcome to")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("HoaxHunter")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Image("world")
                    .resizable()
                    .frame(width: 100,height: 100)
                
                Text("Your Trusted Source for Detecting Fake News")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    LoadingScreen()
}
