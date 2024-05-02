//
//  DetectorNews.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/10/23.
//

import SwiftUI
import CoreML
import Vision
import AVFoundation

struct DetectorNews: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationView{
            TabView(selection: $selectedTab) {
                FirstPage(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scanner")
                    }
                    .tag(0)
                
                SecondPage()
                    .tabItem {
                        Image(systemName: "newspaper")
                        Text("Reports")
                    }
                    .tag(1)
                
                SharedArticlesView()
                    .tabItem { Image(systemName: "globe")
                        Text("Shared")
                    }
                    .tag(2)
                
                Reccomended()
                    .tabItem { Image(systemName: "book")
                        Text("Data")
                    }
                    .tag(3)
                
                Profile()
                    .tabItem { Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(4)
                
            }
        }
        .navigationBarHidden(true)
    }
}

class ReportManager: ObservableObject {
    @Published var reports: [Report]
    
    init(reports: [Report] = []) {
        self.reports = reports
        loadReports()
    }
    
    static func addSample(isFake: Bool, articleName: String, articleContent: String) {
        // Assuming you want to add a sample report directly
        let newReport = Report(articleID: articleName, isFakeNews: isFake, confidences: 0.01, articleContent: articleContent, isPosted: false)
        Self.shared.reports.insert(newReport, at: 0)
        Self.shared.saveReports()
    }

    static var shared = ReportManager()
    
    private let reportsKey = "SavedReports"
    func saveReports() {
        do {
            let data = try JSONEncoder().encode(reports)
            UserDefaults.standard.set(data, forKey: reportsKey)
        } catch {
            print("Failed to save reports: \(error.localizedDescription)")
        }
    }

    func loadReports() {
        if let data = UserDefaults.standard.data(forKey: reportsKey) {
            do {
                reports = try JSONDecoder().decode([Report].self, from: data)
            } catch {
                print("Failed to load reports: \(error.localizedDescription)")
            }
        }
    }
    
    static func doesExist(articleID: String) -> Bool{
        return ReportManager.shared.reports.contains { $0.articleID == articleID }
    }
}

struct FirstPage: View {
    @State public var articleText: String = ""
    static var sharedArticleText = ""
    @State private var isFakeNews: Bool = false
    @State private var scanningProgress: Double = 0.0
    @State private var showingInvalidInputAlert = false
    @State private var showingReportReadyAlert = false
    @State private var showAlert = false
    @StateObject private var reportManager = ReportManager()
    @FocusState private var isTextFieldFocused: Bool
    @Binding var selectedTab: Int
    @State private var isImagePickerPresented: Bool = false

    
    let model = try! NewsClassifierv2(configuration: MLModelConfiguration.init())
    
    static func changeText(value: String){
        sharedArticleText = value
    }
    
    static func getArticleText() -> String{
        return sharedArticleText
    }
    
    @State private var isSheetPresented = false

    var body: some View {
        VStack {
            HStack{
                Text("News Scanner")
                    .font(.title)
                    .padding()
                    .padding(.leading, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
//                NavigationLink(destination: NotificationView()) {
//                    Image(systemName: "bell")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .padding()
//                        .foregroundColor(Color.blue)
//                        .cornerRadius(15)
//                }
                
                Button(action: {
                    isSheetPresented.toggle()
                           }) {
                               Image(systemName: "info.circle")
                                   .font(.title)
                                   .foregroundColor(.blue)
                           }
                           .padding(.trailing, 24) // Adjust the padding as needed
                           .sheet(isPresented: $isSheetPresented){
                               NewsScanInfo(isSheetPresented: $isSheetPresented)
                           }
            }

            HStack {
                TextEditor(text: $articleText)
                   .cornerRadius(10)
                   .padding(20)
                   .background(Color.gray.opacity(0.1))
                   .font(.body) // Adjust the font size as needed
                   .frame(minHeight: 100)
                   .cornerRadius(25)
                   .overlay(
                       Group {
                           if articleText.isEmpty {
                               Text("Enter article here")
                                   .foregroundColor(.gray)
                                   .padding(.horizontal, 8)
                           }
                       }
                   )
                   .focused($isTextFieldFocused)
                   .toolbar {
                       if isTextFieldFocused{
                           ToolbarItem(placement: .keyboard) {
                               HStack {
                                   Spacer()
                                   Button("Done") {
                                       UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                   }
                                   .padding(.horizontal)
                               }
                           }
                       }
                   }
           }
           .padding([.leading, .trailing], 20)

            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                if articleText.isEmpty || articleText.count <= 100 {
                    showingReportReadyAlert = false
                    showAlert = true
                    return
                }
                FirstPage.changeText(value: articleText)
                showAlert = false
                showingReportReadyAlert = true
                articleText = ""
            }) {
                VStack{
                Text("Scan")
                    .padding()
                    .padding(.horizontal, 75)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .alert(isPresented: $showAlert){
                Alert(
                    title: Text("Invalid Input"),
                    message: Text("Please enter an article with at least 100 characters. Character count: " + String(articleText.count)),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingReportReadyAlert){
                Name(showingReportReadyAlert: $showingReportReadyAlert, SelectedTab: $selectedTab)
            }
            Spacer()
        }
        .navigationTitle("News Scanner")
    }
}

struct Report: Identifiable, Codable {
    var id = UUID()
    var articleID: String
    var isFakeNews: Bool
    var confidences: Double
    var articleContent: String
    var isPosted: Bool
    
    func toDictionary() -> [String: Any] {
        return [
            "articleID": articleID,
            "isFakeNews": isFakeNews,
            "confidences": confidences,
            "articleContent": articleContent,
            "isPosted": isPosted
        ]
    }

    init(fromDictionary dictionary: [String: Any]) {
        articleID = dictionary["articleID"] as? String ?? ""
        isFakeNews = dictionary["isFakeNews"] as? Bool ?? false
        confidences = dictionary["confidences"] as? Double ?? 0.0
        articleContent = dictionary["articleContent"] as? String ?? ""
        isPosted = dictionary["isPosted"] as? Bool ?? false
    }
    
    init(articleID: String, isFakeNews: Bool, confidences: Double, articleContent: String, isPosted: Bool) {
        self.articleID = articleID
        self.isFakeNews = isFakeNews
        self.confidences = confidences
        self.articleContent = articleContent
        self.isPosted = isPosted
    }
}

struct SecondPage: View {
    @StateObject private var reportManager = ReportManager.shared
    @State private var isSheetPresented = false

    var body: some View {
        NavigationView{
            VStack {
                HStack{
                    Text("Reports")
                        .font(.title)
                        .padding()
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        isSheetPresented.toggle()
                               }) {
                                   Image(systemName: "info.circle")
                                       .font(.title)
                                       .foregroundColor(.blue)
                               }
                               .padding(.trailing, 24)
                               .sheet(isPresented: $isSheetPresented){
                                   ReportsInfo(isSheetPresented: $isSheetPresented)
                               }
                }
                
                HStack{
                    List {
                        ForEach($reportManager.reports.indices, id: \.self) { index in
                            NavigationLink(destination: InfoScreen(report: $reportManager.reports[index], showPost: Binding<Bool>.constant(true), showUnSave: Binding<Bool>.constant(false))) {
                                ReportItemView(report: $reportManager.reports[index])
                            }
                        }
                        .onDelete { indexSet in
                            reportManager.reports.remove(atOffsets: indexSet)
                            reportManager.saveReports()
                        }
                    }
                    .padding(.top, -15)
                    .padding([.leading, .trailing], 4)
                    .cornerRadius(25)
                    .background(Color.gray.opacity(0.1))
                    .scrollContentBackground(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowSpacing(10)
                    .cornerRadius(25)
                    .padding(.bottom, 25)
                    .overlay(
                        Group {
                            if $reportManager.reports.isEmpty {
                                Text("No Article Reports")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                            }
                        }
                    )
                }
                .padding([.leading, .trailing], 20) // Adjust the side padding as needed
            }
        }
    }
}

struct ReportItemView: View {
    @Binding var report: Report

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Article: \(report.articleID)")
                    .font(.headline)
                Text("Fake News: \(report.isFakeNews ? "Yes" : "No")")
                //Text("Confidence: \(Int(report.confidences * 100))%")
            }
        }
        .padding()
    }
}


#Preview {
    DetectorNews()
}
