//
//  NewsScanInfo.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/4/24.
//

import SwiftUI

struct NewsScanInfo: View {
    @Binding var isSheetPresented: Bool

    var body: some View {
        VStack {
            Text("Entering your Articles")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("HoaxHunter")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Image("world")
                .resizable()
                .frame(width: 100,height: 100)
            
            Text("Enter your text into the text field and then press enter, you will be prompted to enter a title before you can start the scanning process. The Scanner page represents a news scanner interface where users can input and scan articles for validity. It includes features like entering article text, scanning for fake news, handling user input validation, and presenting alerts and sheets for user interactions. The view also utilizes local iPhone storage for managing report data and includes functionality to share article text across different views.")
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
