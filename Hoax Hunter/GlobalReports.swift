//
//  GlobalReports.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/4/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class GlobalReports: ObservableObject {
    let database = Firestore.firestore()
    @Published var reports: [Report] = []
    static var isFiltered = false
    
    let objectionableKeywords = [
        "Political", "Hate speech", "Racism", "darkness", "Discrimination", "Profanity", "Vulgarity", "Obscenity", "Pornography", "Sexual content",
        "Nudity", "Explicit", "Adult", "Violence", "Gore", "Blood", "Weapons", "Terrorism", "Extremism", "Suicide",
        "Self-harm", "Drugs", "Alcohol", "Tobacco", "Addiction", "Gambling", "Fraud", "Scam", "Phishing", "Malware",
        "Virus", "Hacking", "Piracy", "Copyright infringement", "Plagiarism", "Fraudulent activities", "Illegal activities", "Weapons trafficking", "Human trafficking", "Child exploitation",
        "Child abuse", "Animal cruelty", "Environmental damage", "Hate groups", "Cults", "Harassment", "Bullying", "Cyberbullying",
        "Stalking", "Intimidation", "Threats", "Blackmail", "Extortion", "Revenge porn", "Discriminatory language", "Derogatory terms",
        "Racial slurs", "Ethnic slurs", "Homophobic language", "Transphobic language", "Misogynistic language", "Sexist language", "Ageist language", "Ableist language", "Religious intolerance",
        "Anti-Semitism", "Islamophobia", "Xenophobia", "Nationalism", "Fascism", "Communism", "Anarchism", "Radical ideologies", "Propaganda",
        "Misinformation", "Fake news", "Conspiracy theories", "Pseudoscience", "Quackery", "Hoaxes", "Urban legends", "Slander",
        "Libel", "Defamation", "Character assassination", "Identity theft", "Impersonation", "Privacy violations", "Data breaches", "Cyberattacks",
        "Online scams", "Pyramid schemes", "Multi-level marketing", "Ponzi schemes", "Financial fraud", "Money laundering", "Tax evasion", "Insider trading",
        "Stock manipulation", "Bribery", "Corruption", "Embezzlement", "Fraudulent claims", "False promises", "Deceptive advertising", "Manipulative tactics",
        "Coercion", "Brainwashing", "Gaslighting", "Psychological abuse", "Emotional manipulation", "Narcissism", "Sociopathy", "Psychopathy", "Anti-social behavior",
        "Antagonistic behavior", "Destructive behavior", "Malicious intent", "Malicious software", "Cybercrime", "Cyberterrorism", "Cyberbullying", "Cyberstalking", "Cyberharassment",
        "Cyberextortion", "Cyberattacks", "Cyberespionage", "Cyberwarfare", "Phishing scams", "Social engineering", "Password theft", "Account hijacking", "Botnets",
        "Denial of Service (DoS)", "Distributed Denial of Service (DDoS)", "Spoofing", "Keylogging", "Ransomware", "Spyware", "Adware", "Browser hijacking",
        "Online harassment", "Trolling", "Flame wars", "Doxing", "Swatting", "Ghosting", "Catfishing", "Impersonation scams", "Romance scams",
        "Sextortion", "Cyberbullying", "Cyberstalking", "Cyberharassment", "Cyberattacks", "Cyberextortion", "Cyberespionage", "Cyberwarfare", "Phishing scams",
        "Social engineering", "Password theft", "Account hijacking", "Botnets", "Denial of Service (DoS)", "Distributed Denial of Service (DDoS)", "Spoofing",
        "Keylogging", "Ransomware", "Spyware", "Adware", "Browser hijacking", "Online harassment", "Trolling", "Flame wars", "Doxing",
    "Swatting", "Ghosting", "Catfishing", "Impersonation scams", "Romance scams", "Sex", "Dick", "Porn", "Kill", "Drug", "Foul", "Vile", "Evil", "Gore", "Lust"]

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

        let docRef =  Firestore.firestore().document("hoaxhunter/\(articleID)")

            docRef.delete { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                } else {
                    print("Document deleted successfully!")
                }
            }
        }

    static var shared = GlobalReports()
    
    private let reportsKey = "GlobalReports"
    func saveReports() {
        do {
            let data = try JSONEncoder().encode(reports)
            UserDefaults.standard.set(data, forKey: reportsKey)
        } catch {
            print("Failed to save reports: \(error.localizedDescription)")
        }
    }

    func loadReports() {
        reports.removeAll()
        let docRef = Firestore.firestore().collection("hoaxhunter")
        fetchFilterStatus()
        print(GlobalReports.isFiltered)

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
                
                let report = Report(articleID: articleID, isFakeNews: isFakeNews, confidences: confidences, articleContent: articleContent, isPosted: isPosted)
                
                Self.shared.reports.insert(report, at: 0)
            }
            
            if(GlobalReports.isFiltered && Self.shared.reports.isEmpty){
                let report = Report(articleID: "Content Filtered", isFakeNews: false, confidences: 0.01, articleContent: "Currently your content is being filtered. You can change the filter status in this page.", isPosted: true)
                
                Self.shared.reports.insert(report, at: 0)
            }
            
            Self.shared.saveReports()
        }
    }
    
    public func containsObjectionableKeywords(_ content: String) -> Bool {
        let loweredContent = content.lowercased()
        for keyword in objectionableKeywords {
            if loweredContent.contains(keyword.lowercased()) {
                return true
            }
        }
        return false
    }
    
    func writeData(articleID: String, isFakeNews: Bool, confidences: Double, articleContent: String, isPosted: Bool) {
        let docRef = database.document("hoaxhunter/\(articleID)")

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
    
    private func fetchFilterStatus() {
        let db = Firestore.firestore()
        
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("user").document(userID).getDocument { document, error in
                if let document = document, document.exists {
                    if let isFlagged = document.data()?["isFiltered"] as? Bool {
                        DispatchQueue.main.async {
                            print(isFlagged)
                            GlobalReports.isFiltered = isFlagged
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    public func fetchFilterStatusTest() -> Bool {
        let db = Firestore.firestore()
        var doubleVal = true
        
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("user").document(userID).getDocument { document, error in
                if let document = document, document.exists {
                    if let isFlagged = document.data()?["isFiltered"] as? Bool {
                        DispatchQueue.main.async {
                            doubleVal = isFlagged
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        return doubleVal
    }
}
