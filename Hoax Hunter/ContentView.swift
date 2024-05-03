//
//  ContentView.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/8/23.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isSheetPresented: Bool
    
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

                NavigationLink(destination: TeachScreen1(isSheetPresented: $isSheetPresented)) {
                    Text("Get Started")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
}

#Preview{
    WelcomeView(isSheetPresented: Binding<Bool>.constant(true))
}
