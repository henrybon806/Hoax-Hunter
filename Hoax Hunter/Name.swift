//
//  Name.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 11/15/23.
//

import SwiftUI
import CoreML

struct Name: View {
    @State private var articleTitle = ""
    @State private var showArticleTitle = false
    @State private var showAlert = false
    @FocusState private var isTextFieldFocused: Bool
    @State var fake = false
    @Binding var showingReportReadyAlert: Bool
    @Binding var SelectedTab: Int
    
    let model = try! NewsClassifierv2(configuration: MLModelConfiguration.init())
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Enter the Title of the Article:")
                    .font(.headline)
                    .padding()
                    .padding(.top, -30)
                HStack{
                    TextField("Title", text: $articleTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .submitLabel(.done)
                        .focused($isTextFieldFocused)
                }
                
                Button(action: close) {
                    VStack{
                        Text("Enter")
                            .padding()
                            .padding(.horizontal, 75)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .alert(isPresented: $showAlert){
                    if showArticleTitle{
                        Alert(
                            title: Text("Invalid Input"),
                            message: Text("Please enter a valid title"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    else{
                        Alert(
                            title: Text("Scanning Complete"),
                            message: Text("You can now view your report"),
                            dismissButton: .default(Text("OK")){
                                showingReportReadyAlert.toggle()
                                SelectedTab = 1
                            }
                        )
                    }
                }
                .padding()
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                showingReportReadyAlert.toggle()
            })
        }
    }
    
    func close() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if(articleTitle.isEmpty){
            showArticleTitle.toggle()
            showAlert.toggle()
            return
        }
        showArticleTitle = false
        startScanning()
    }
    
    func startScanning() {
        let instance = FirstPage.getArticleText()
        print(instance)

        let machineModel = NewsClassifierv2Input(text: instance)
        
        guard let isFake = try? model.prediction(input: machineModel) else{
            fatalError("Unexpected runtime error.")
        }
        
        if(isFake.featureValue(for: "label")?.stringValue == "Fake"){
            fake = true
        }
        
        ReportManager.addSample(isFake: fake, articleName: articleTitle, articleContent: FirstPage.getArticleText())
        showAlert.toggle()
        return
    }
}

#Preview {
    Name(showingReportReadyAlert: Binding<Bool>.constant(true), SelectedTab: Binding<Int>.constant(0))
}
