//
//  OptionsSheet.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 5/1/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OptionsSheet: View {
    @Binding var articleID: String
    @State private var isContentFiltered = false
    @State private var isContentFlagged = false
    @State private var isUserBlocked = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Content Options")
                .font(.title)
                .padding(.bottom, 5)
            
            Divider()
                .padding(.bottom, 10)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                Toggle("Filter Objectionable Content", isOn: $isContentFiltered)
                    .onChange(of: isContentFiltered) { newValue in
                        updateFilteredContentStatus(filtered: newValue)
                    }
            }
            .padding(.bottom, 10)
            
            Text("Enable this option to automatically filter objectionable content from appearing in your feed. This helps maintain a safer and more enjoyable browsing experience.")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.bottom, 5)

            HStack {
                Image(systemName: isContentFlagged ? "flag.fill" : "flag")
                    .foregroundColor(isContentFlagged ? .red : .blue)
                Button(action: {
                    isContentFlagged.toggle()
                    alertMessage = isContentFlagged ? "Content Flagged. We have recorded that you believe this is flagged content and will be reviewed by one of our team members within 24 hours." : "Content Unflagged. You can undo this at any time."
                    
                    updateFlaggedContentStatus(flagged: isContentFlagged)
                    showAlert = true
                }) {
                    Text(isContentFlagged ? "Unflag Content" : "Flag Objectionable Content")
                        .foregroundColor(isContentFlagged ? .red : .blue)
                }
            }
            .padding(.bottom, 10)
            Text("Flag content as objectionable to report inappropriate posts or articles. This action helps maintain a healthy community by notifying moderators of potential issues.")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.bottom, 5)

//            HStack {
////                Image(systemName: isUserBlocked ? "xmark.circle.fill" : "xmark.circle")
////                    .foregroundColor(isUserBlocked ? .red : .blue)
////                Button(action: {
////                    isUserBlocked.toggle()
////                    alertMessage = isUserBlocked ? "User Blocked. Please see your blocked users from the global reports page." : "User Unblocked. You can undo this action at any time."
////                    
////                    updateUserBlockedStatus(blocked: isUserBlocked)
////                    showAlert = true
////                }) {
////                    Text(isUserBlocked ? "Unblock User" : "Block Abusive User")
////                        .foregroundColor(isUserBlocked ? .red : .blue)
////                }
//            }
//            Text("Block abusive users to prevent them from interacting with you. This action helps maintain a positive and respectful online environment.")
//                .foregroundColor(.gray)
//                .font(.caption)
            
            Divider()
                .padding(.vertical, 10)

            VStack(alignment: .leading) {
                Text("It's crucial for all users to adhere to the End User License Agreement (EULA) rules and regulations to ensure a safe and respectful online environment for everyone.")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.bottom, 10)
                
               // Spacer()
                
                Text("This URL shows the End User License Agreement (EULA) website, where you can find detailed information about the terms and conditions governing your use of this platform.")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Link(destination: URL(string: "https://sites.google.com/view/hoaxhuntereula/home")!) {
                    Text("Read EULA here")
                        .foregroundColor(.blue)
                        .font(.caption)
                        .bold()
                }
            }

            Spacer()
                .frame(maxHeight: .infinity)

            HStack {
                Spacer()

                Image(systemName: "globe")
                    .foregroundColor(.blue)
                    .font(.title)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Action Completed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            fetchFlaggedContentStatus()
            fetchFilterStatus()
        }
    }
    
    private func updateFilteredContentStatus(filtered: Bool) {
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("user").document(userID).updateData(["isFiltered": filtered])
        }
    }
    
    private func updateFlaggedContentStatus(flagged: Bool) {
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.uid {
            db.collection(userID + "flagged").document(articleID).setData(["isFlagged": flagged])
        }
    }

    private func updateUserBlockedStatus(blocked: Bool) {
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.uid {
            db.collection(userID + "blocked").document("userID").setData(["isBlocked": blocked])
        }
    }
    
    private func fetchFlaggedContentStatus() {
        let db = Firestore.firestore()
        let contentID = articleID
    
        if let userID = Auth.auth().currentUser?.uid {
            db.collection(userID + "flagged").document(contentID).getDocument { document, error in
                if let document = document, document.exists {
                    if let isFlagged = document.data()?["isFlagged"] as? Bool {
                        DispatchQueue.main.async {
                            self.isContentFlagged = isFlagged
                        }
                    }
                } else {
                    print("Document does not exist")
                }
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
                            self.isContentFiltered = isFlagged
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.title)
            .padding()
    }
}
