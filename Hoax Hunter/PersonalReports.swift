//
//  PersonalReports.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/12/24.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class PersonalReports: ObservableObject {
    let database = Firestore.firestore()
    @Published var reports: [Report] = []

    init(reports: [Report] = []) {
        self.reports = reports
        loadReports()
    }

    static func addSample(isFake: Bool, articleName: String, articleContent: String) {
        let newReport = Report(articleID: articleName, isFakeNews: isFake, confidences: 0.01, articleContent: articleContent, isPosted: true)
        Self.shared.reports.insert(newReport, at: 0)
        Self.shared.saveReports()
        Self.shared.writeData(articleID: articleName, isFakeNews: isFake, confidences: 0.01, articleContent: articleContent, isPosted: true )
    }
    
    static func unpostArticle(articleID: String) {
        Self.shared.reports.removeAll { $0.articleID == articleID }
        Self.shared.saveReports()

        let docRef =  Firestore.firestore().document("\(Auth.auth().currentUser!.uid)/\(articleID)")
            docRef.delete { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                } else {
                    print("Document deleted successfully!")
                }
            }
        }

    static var shared = PersonalReports()
    
    private let reportsKey = "PersonalReports"
    func saveReports() {
        do {
            let data = try JSONEncoder().encode(reports)
            UserDefaults.standard.set(data, forKey: reportsKey)
        } catch {
            print("Failed to save reports: \(error.localizedDescription)")
        }
    }
    
    func calculateUserTrustScore() -> String {
        var totalFakes = 0
        for report in PersonalReports.shared.reports {
            if(!report.isFakeNews){
                totalFakes += 1
            }
        }
        if(Double(PersonalReports.shared.reports.count) > 0){
            return   String(format: "%.2f", Double(totalFakes) / Double(PersonalReports.shared.reports.count) * 100) + "%"
        }
        return "0.00%"
    }

    func loadReports() {
        let docRef = Firestore.firestore().collection("\(Auth.auth().currentUser!.uid)")

        docRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error loading reports: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }

            // Process each document
            for document in documents {
                let data = document.data()
                let articleID = document.documentID
                let isFakeNews = data["isFakeNews"] as? Bool ?? false
                let confidences = data["confidences"] as? Double ?? 0.0
                let articleContent = data["articleContent"] as? String ?? ""
                let isPosted = data["isPosted"] as? Bool ?? false

                // Create a Report object or perform other operations with the data
                let report = Report(articleID: articleID, isFakeNews: isFakeNews, confidences: confidences, articleContent: articleContent, isPosted: isPosted)

                // Handle the report object as needed, such as adding it to an array or processing it further
                Self.shared.reports.insert(report, at: 0)
            }
            
            Self.shared.saveReports()
        }
    }
    
    func writeData(articleID: String, isFakeNews: Bool, confidences: Double, articleContent: String, isPosted: Bool) {
        let docRef = database.document("\(Auth.auth().currentUser!.uid)/\(articleID)")

          let data: [String: Any] = [
              "articleID": articleID,
              "isFakeNews": isFakeNews,
              "confidences": confidences,
              "articleContent": articleContent,
              "isPosted": isPosted
          ]

          docRef.setData(data) { error in
              if let error = error {
                  print("Error writing document: \(error.localizedDescription)")
              } else {
                  print("Document successfully written!")
                  // You can update your UI or perform other actions after successfully writing data
              }
          }
    }
}
