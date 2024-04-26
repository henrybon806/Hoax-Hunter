//
//  Reccomended.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/7/24.
//

import SwiftUI
import Firebase

struct Reccomended: View {
    @State private var isSheetPresented = false
    @State public var articleText: String = ""
    static var sharedArticleText = ""
    @State private var isFakeNews: Bool = false
    @State private var scanningProgress: Double = 0.0
    @State private var showingInvalidInputAlert = false
    @State private var showingReportReadyAlert = false
    @State private var showAlert = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        NavigationView{
            VStack {
                VStack{
                    HStack{
                        Text("Data")
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
                            RecommendationInfo(isSheetPresented: $isSheetPresented)
                        }
                    }
                    Text("Our machine learning model is still new - and we would love new data. Please send any articles with their correct fake news status to be reviewed by one of our team members. ")
                        .font(.caption)
                        .padding()
                        .padding(.top, -20)
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HStack {
                    TextEditor(text: $articleText)
                        .cornerRadius(10)
                        .padding(20)
                        .background(Color.gray.opacity(0.1))
                        .font(.body)
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
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isFakeNews = false
                    }) {
                        Text("True News")
                            .foregroundColor(isFakeNews ? .gray : .blue)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        isFakeNews = true
                    }) {
                        Text("Fake News")
                            .foregroundColor(isFakeNews ? .blue : .gray)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
                
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    if articleText.isEmpty || articleText.count <= 100 {
                        showingReportReadyAlert = false
                        showAlert = true
                        return
                    }
                    writeData(articleContent: articleText, isFakeNews: isFakeNews)
                    showingReportReadyAlert = true
                    showAlert = true
                    articleText = ""
                }) {
                    VStack{
                        Text("Send Data")
                            .padding()
                            .padding(.horizontal, 75)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .alert(isPresented: $showAlert){
                    if(!showingReportReadyAlert){
                        Alert(
                            title: Text("Invalid Input"),
                            message: Text("Please enter an article with at least 100 characters. Character count: " + String(articleText.count)),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    else{
                        Alert(
                            title: Text("Thank you"),
                            message: Text("We appreciate your help training our models"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
    }
    
    func writeData(articleContent: String, isFakeNews: Bool) {
        let docRef = Firestore.firestore().document("helpData/\(String(articleContent.prefix(20)))")

          let data: [String: Any] = [
              "articleContent": articleContent,
              "isFakeNews": isFakeNews,
          ]

          docRef.setData(data) { error in
              if let error = error {
                  print("Error writing document: \(error.localizedDescription)")
              } else {
                  print("Document successfully written!")
              }
          }
    }
}

#Preview {
    Reccomended()
}
