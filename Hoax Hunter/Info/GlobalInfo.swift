//
//  GlobalInfo.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/4/24.
//

import SwiftUI

struct GlobalInfo: View {
    @Binding var isSheetPresented: Bool

    var body: some View {
        VStack {
            Text("View Shared Articles")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("HoaxHunter")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Image("world")
                .resizable()
                .frame(width: 100,height: 100)
            
            Text("These articles are not viewed prior to posting; however, will be taken down if they are not respectful to others. The Global Reports page presents a list of global reports with navigation functionality to view detailed information about each report. It includes features such as displaying report items, handling navigation, and providing an option to access additional global information. The view utilizes worldwide users as its data source, suggesting a shared context for managing global report data across the application.")
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
