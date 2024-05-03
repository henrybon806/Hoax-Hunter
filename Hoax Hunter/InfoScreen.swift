//
//  InfoScreen.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/23/23.
//

import SwiftUI
import Firebase
import Foundation
import UIKit

struct InfoScreen: View {
    @Binding var report: Report
        @Binding var showPost: Bool
        @Binding var showUnSave: Bool
        @State private var isAlertPresented = false
        @State private var showOptionsSheet = false
        @State private var isContentFlagged = false
        static var closePage = false
        static var labeltbh = "Unsave"
        static var check: Bool = false
        @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack{
                Text("Article Title:")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding(.trailing, -15)
                
                Text(report.articleID)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .padding(.bottom, -20)
            
            HStack{
                Text("Fake News:")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding(.trailing, -15)
                
                Text(report.isFakeNews ? "Yes" : "No")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .padding(.bottom, -5)

            Text("Article Content:")
                .font(.title)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack{
                ScrollView {
                    Text(report.articleContent)
                        .font(.body)
                        .padding(10)
                        .padding(.top, -5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(25)
            
            if(showPost){
                Button(action: {
                    if report.isPosted {
                        GlobalReports.unpostArticle(articleID: report.articleID)
                        report.isPosted = false
                        isAlertPresented = true
                    }
                    else {
                        isAlertPresented = true
                        report.isPosted = true
                    }
                    ReportManager.shared.saveReports()
                }) {
                    VStack{
                        Text(report.isPosted ? "Unpost" : "Post")
                            .padding()
                            .padding(.horizontal, 75)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .alert(isPresented: $isAlertPresented) {
                    if(report.isPosted){
                        Alert(
                            title: Text("Article Posted"),
                            message: Text("Article is now posted. Please be respectful when posting articles online and follow EULA."),
                            dismissButton: .default(Text("OK")) {
                                report.isPosted = true
                                GlobalReports.addSample(isFake: report.isFakeNews, articleName: report.articleID, articleContent: report.articleContent)
                            }
                        )
                    }
                    else{
                        Alert(
                            title: Text("Article Unposted"),
                            message: Text("Article is now unposted. You can undo this action at any time."),
                            dismissButton: .default(Text("OK")) {
                                report.isPosted = false
                            }
                        )
                    }
                }
            }

            Spacer()
        }
        .padding()
        .padding(.top, -15)
        .navigationTitle("Report Detail")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                if(!showUnSave){
                    HStack{
                        Button(action: {
                            PersonalReports.addSample(isFake: report.isFakeNews, articleName: report.articleID, articleContent: report.articleContent)
                            PersonalReports.shared.saveReports()
                        }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                        
                        if(!ReportManager.doesExist(articleID: report.articleID)){
                            Button(action: {
                                showOptionsSheet = true
                            }) {
                                Image(systemName: "ellipsis.circle")
                            }
                            .sheet(isPresented: $showOptionsSheet) {
                                OptionsSheet(articleID: Binding<String>.constant(report.articleID))
                            }
                        }
                    }
                }
                else{
                    Button(action: {
                        PersonalReports.unpostArticle(articleID: report.articleID)
                        PersonalReports.shared.saveReports()
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(InfoScreen.labeltbh)
                    }
                }
            }
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
                InfoScreen.labeltbh = "\(error.localizedDescription)"
            } else {
                print("Notification scheduled successfully.")
                InfoScreen.labeltbh = "success"
            }
        }
    }
    
    func checkIfExists(){
        InfoScreen.check = false
        let docRef = Firestore.firestore().collection("\(Auth.auth().currentUser!.uid)")

        docRef.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }

            for document in documents {
                let articleID = document.documentID
                
                if(report.articleID == articleID){
                    InfoScreen.check = true
                    break
                }
            }
        }
    }
}

#Preview {
    InfoScreen(report: Binding<Report>.constant(Report(articleID: "Sample", isFakeNews: true, confidences: 0.01, articleContent: "Lorem Ipsum", isPosted: false)), showPost: Binding<Bool>.constant(true), showUnSave: Binding<Bool>.constant(false))
}
