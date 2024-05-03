//
//  TeachScreen1.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/23/23.
//

import SwiftUI

struct TeachScreen1: View {
    @Binding var isSheetPresented: Bool
    @State private var description: String = ""
    @State private var title: String = ""
    
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
            
            Text("Enter your text into the text field and then press enter, you will be prompted to enter a title before you can start the scanning process. Once the scan process is complete the data will be saved on your personal device. To save the article to the cloud, open the saved article in the reports page and click the save icon on the top right corner. The new saved report will appear in your profile page, and allow you to unsave at any time. You will also recieve a \"trust score\" which allows you to see the percentage of fake news you read based on the data in your saved reports. You can also provide us with data to improve our models in the Data page. Continue to the next page to learn about article sharing..." )
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: TeachScreen2(isSheetPresented: $isSheetPresented)) {
                Text("Next")
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

#Preview {
    TeachScreen1(isSheetPresented: Binding<Bool>.constant(true))
}
