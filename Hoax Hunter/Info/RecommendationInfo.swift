//
//  RecommendationIndo.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/8/24.
//

import SwiftUI

struct RecommendationInfo: View {
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
            
            Text("This is the recommendation page where you can help add data to our existing machine learning model. The Recommended page allows users to input article text and classify it as true or fake news. It integrates with our databases to store this data for model training, providing users with a simple interface to contribute to improving the app's machine learning capabilities.")
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
