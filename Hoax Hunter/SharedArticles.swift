//
//  Analytics.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/4/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SharedArticlesView: View {
    @StateObject private var reportManager = GlobalReports.shared
    @State private var isSheetPresented = false
    @State var isFiltered = false

    var body: some View {
            NavigationView{
                VStack {
                    HStack{
                        Text("Global Reports")
                            .font(.title)
                            .padding()
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            reportManager.loadReports()
                            fetchFilterStatus()
                       }) {
                           Image(systemName: "arrow.clockwise.circle.fill")
                               .font(.title)
                               .foregroundColor(.blue)
                       }

                        Button(action: {
                            isSheetPresented.toggle()
                                   }) {
                                       Image(systemName: "info.circle")
                                           .font(.title)
                                           .foregroundColor(.blue)
                                   }
                                   .padding(.trailing, 24)
                                   .sheet(isPresented: $isSheetPresented){
                                       GlobalInfo(isSheetPresented: $isSheetPresented)
                                   }
                    }
                    
                    HStack{
                        List {
                            ForEach($reportManager.reports.indices, id: \.self) { index in
                                if(!reportManager.containsObjectionableKeywords(reportManager.reports[index].articleContent) ||  !isFiltered){
                                    NavigationLink(destination: InfoScreen(report: $reportManager.reports[index], showPost: Binding<Bool>.constant(false), showUnSave: Binding<Bool>.constant(false))) {
                                        ReportItemView(report: $reportManager.reports[index])
                                    }
                                }
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
                                    Text("No Shared Reports")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                }
                            }
                        )
                    }
                    .padding([.leading, .trailing], 20)
                }
            }
            .onAppear(){
                fetchFilterStatus()
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
                            isFiltered = isFlagged
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}


#Preview {
    SharedArticlesView()
}
