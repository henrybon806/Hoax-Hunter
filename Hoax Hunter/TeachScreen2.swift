//
//  TeachScreen2.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/23/23.
//

import SwiftUI

struct TeachScreen2: View {
    @Binding var isSheetPresented: Bool
    var hello = false
    
    var body: some View {
        VStack {
            Text("Viewing Results")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("HoaxHunter")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Image("world")
                .resizable()
                .frame(width: 100,height: 100)
            
            Text("Navigate to the reports page, the article data will be presented with the article title you created so you will know which article was scanned. In this page you can also post an article for the internet to see. Anytime an article is posted, all users will be notified of the article title, and will be able to read instantly on their global reports page. You can save anyone's global report to your saved reports; however, cannot remove someone else's report from your global reports page. This app allows you to detect fake news and share it to the world in a moments notice. You can also update your name, email, password and even add a profile picture in your profile page. Have fun Hoax Hunters - we can't wait to see what you make!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
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
        .padding()
    }
}

#Preview {
    TeachScreen2(isSheetPresented: Binding<Bool>.constant(true))
}
