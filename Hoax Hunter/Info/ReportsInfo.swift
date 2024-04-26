//
//  ReportsInfo.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/4/24.
//

import SwiftUI

struct ReportsInfo: View {
    @Binding var isSheetPresented: Bool

    var body: some View {
        VStack {
            Text("View your Articles")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("HoaxHunter")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Image("world")
                .resizable()
                .frame(width: 100,height: 100)
            
            Text("Click to view any of your previous articles. You can also share your articles to the world here. The Reports page displays a list of reports with navigation functionality to view detailed information about each report. It includes features such as deleting reports, handling navigation, and presenting additional information about the reports. The view utilizes your local iPhone storage as its data source, suggesting a shared context for managing report data across the application. All reports are automatically saved locally on your phone; however, not uploaded to your account until you save them.")
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
