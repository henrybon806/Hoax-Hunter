//
//  Profile.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/7/24.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct Profile: View {
    @State private var displayName: String = ""
    @State private var profilePicURL: URL?
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isVerified: Bool = false
    @State private var privacySetting: Bool = true
    @State private var notificationSetting: Bool = true
    @State private var trustScore: String = "0.00%"
    @State private var firstNameInput: String = ""
    @State private var lastNameInput: String = ""
    @State private var showAlert = false
    @State private var showAlert2 = false
    @State private var alertMessage = ""
    @State private var deleteAccount = false
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var isChangingEmail = false
    @State private var isLoggedOut = true
    @State private var email: String = "(email)"
    @State private var isEditingName: Bool = false
    @State private var showVAlert = false
    @State private var isEditingVerification: Bool = false
    @State private var isSheetPresented = false
    @StateObject private var reportManager = PersonalReports.shared
    let database = Firestore.firestore()
    @AppStorage("sendNotif", store: .standard) var sendNotif = true
    
    var body: some View {
            VStack {
                HStack{
                    Text("Profile")
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
                        ProfileInfo(isSheetPresented: $isSheetPresented)
                    }
                }
                
                HStack(spacing: 20) {
                    Image(uiImage: selectedImage ?? UIImage(systemName: "person.circle.fill")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                        .onTapGesture {
                            isShowingImagePicker.toggle()
                            //loadImage()
                        }
                    
                    VStack(alignment: .leading) {
                        Button(action: {
                            isEditingName = true
                        }) {
                            if(displayName.isEmpty){
                                Text("Click to enter name")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 4)
                            }
                            else{
                                Text(displayName)
                                    .font(.title2)
                                    .foregroundColor(.black)
                                    .padding(.bottom, 4)
                            }
                        }
                        
                        if isVerified {
                            Text("Verified")
                                .foregroundColor(.green)
                                .padding(.bottom, 4)
                        }
                        else{
                            Text("Not Verified")
                                .foregroundColor(.red)
                                .padding(.bottom, 4)
                                .onTapGesture {
                                    isEditingVerification = true
                                    showVAlert = true
                                }
                        }
                        
                        Text("Trust Score: \(trustScore)")
                            .font(.subheadline)
                    }
                    .alert("Verification", isPresented: $isEditingVerification){
                        
                    } message: {
                        Text("An email verification has been sent.")
                    }
                    Spacer()
                }
                .padding()
                .padding(.leading, 10)
                .padding(.top, -20)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Notification Preferences:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Toggle(isOn: $notificationSetting) {
                        Text("Receive notifications")
                    }
                    .padding(.bottom, 8)
                    .onChange(of: notificationSetting){ newValue in
                        UserDefaults.standard.set(notificationSetting, forKey: "sendNotif")
                        
                        if(notificationSetting){
                            UserDefaults.standard.set(true, forKey: "sendNotif")
                            let docRef = database.document("tokens/\(UserDefaults.standard.string(forKey: "fcm")!)")
                            
                            let data: [String: Any] = [
                                "token": UserDefaults.standard.string(forKey: "fcm")!
                            ]

                            docRef.setData(data) { error in
                              if let error = error {
                                  print("Error writing document: \(error.localizedDescription)")
                              } else {
                                  print("Document successfully written!")
                              }
                          }
                        }
                        else{
                            UserDefaults.standard.set(false, forKey: "sendNotif")
                            
                            let docRef =  Firestore.firestore().document("tokens/\(UserDefaults.standard.string(forKey: "fcm")!)")

                            docRef.delete { error in
                                if let error = error {
                                    print("Error deleting document: \(error.localizedDescription)")
                                } else {
                                    print("Document deleted successfully!")
                                }
                            }
                        }
                    }
                }
                .padding()
                .padding([.leading, .trailing], 10)
                
                VStack(alignment: .leading) {
                    Text("Account:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    HStack{
                        Text(email)
                            .padding(.bottom, 8)
                        
                        Spacer()
                        
                        Text("Change Email")
                            .padding(.bottom, 8)
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                isChangingEmail = true
                                showAlert = true
                            }
                    }
                    .padding(.top, 4)
                    
                    HStack{
                        Text("")
                            .padding(.bottom, 8)
                        
                        Spacer()
                        
                        Text("Change password")
                            .padding(.bottom, 8)
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                isChangingEmail = false
                                showAlert = true
                            }
                    }
                }
                .padding()
                .padding([.leading, .trailing], 10)
                .padding(.top, -30)
                .alert(isChangingEmail ? "Change Email" : "Change Password", isPresented: $showAlert){
                    if(isChangingEmail){
                        TextField("Email", text: $newEmail)
                        Button("Confirm") {
                            updateEmail(newEmail: newEmail)
                        }
                        Button("Cancel", role: .cancel){}
                    }
                    else{
                        Button("Confirm") {
                            sendPasswordResetEmail(username: email)
                        }
                        Button("Cancel", role: .cancel){}
                    }
                } message: {
                    if(isChangingEmail){
                        Text("Enter new email address:")
                    }
                    else{
                        Text("Are you sure you would like to change your password?")
                    }
                }
                .alert("Updating Email", isPresented: $showAlert2){
                    Button("OK", role: .none){}
                } message: {
                    Text(alertMessage)
                }
                
                VStack(alignment: .leading){
                    Text("Saved Reports:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    HStack{
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach($reportManager.reports.indices, id: \.self) { index in
                                    let destination = InfoScreen(
                                        report: $reportManager.reports[index],
                                        showPost: Binding<Bool>.constant(false),
                                        showUnSave: Binding<Bool>.constant(true)
                                    )

                                    let itemView = ItemView(report: $reportManager.reports[index])
                                        .foregroundStyle(.black)
                                        .frame(minWidth: 130, maxWidth: 130, minHeight: 130, maxHeight: 130)
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .onAppear{
                                            fetchUserData()
                                        }
                                    
                                    NavigationLink(destination: destination) {
                                        itemView
                                            .padding(20)
                                            .padding(.leading, -4)
                                            .padding(.trailing, -25)
                                            .padding(.bottom, -15)
                                    }
                                }
                            }
                        }
                    }
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
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
                                Text("No Saved Reports")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.top, -17)
                            }
                        }
                    )
                }
                .padding()
                .padding([.leading, .trailing], 10)
                .padding(.top, -30)
                .padding(.bottom, -35)
                
                HStack{
                    Button(action: {
                        UserDefaults.standard.set(false, forKey: "rememberLogin")
                        UserDefaults.standard.set("", forKey: "storedEmail")
                        UserDefaults.standard.set("", forKey: "storedPassword")
                        
                        isLoggedOut = true
                    }) {
                        VStack{
                            Text("Log Out")
                                .padding()
                                .padding(.horizontal, 25)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: {
                        deleteAccount = true
                    }) {
                        VStack{
                            Text("Delete Account")
                                .padding()
                                .padding(.horizontal, 15)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .alert(isPresented: $deleteAccount) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone. This will delete all of your stored data."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteUser()
                            },
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                }
                .padding()
                
                NavigationLink(
                    destination: Login(hasShownSheet: Binding<Bool>.constant(true)),
                    isActive: $isLoggedOut,
                    label: { EmptyView() }
                )
                .hidden()
                .transition(.identity)
            }
            .onAppear {
                fetchUserData()
            }
            .alert("Name", isPresented: $isEditingName){
                TextField("First Name", text: $firstNameInput)
                    .textInputAutocapitalization(.never)
                TextField("Last Name", text: $lastNameInput)
                Button("Save", action: save)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enter your username and password.")
            }
            .sheet(isPresented: $isShowingImagePicker) {
                saveImage()
            } content: {
                ImagePicker(selectedImage: $selectedImage, isShowingImagePicker: $isShowingImagePicker)
            }
    }
    
    func authenticate() {
        displayName = firstNameInput
        displayName += " " + lastNameInput
    }
    
    func deleteUser() {
            UserDefaults.standard.set(false, forKey: "rememberLogin")
            UserDefaults.standard.set("", forKey: "storedEmail")
            UserDefaults.standard.set("", forKey: "storedPassword")

            let user = Auth.auth().currentUser

            user?.delete { error in
                if let error = error {
                    print("Unable to delete user:", error.localizedDescription)
                } else {
                    print("Account deleted successfully")
                }
            }

            isLoggedOut = true
        }
    
    func loadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let imageName = "\(String(describing: Auth.auth().currentUser?.uid)).jpg"
        let imageRef = storageRef.child("profileImages/\(imageName)")
        
        imageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image data: \(error.localizedDescription)")
                return
            }
            
            if let imageData = data, let image = UIImage(data: imageData) {
                selectedImage = image
            }
        }
    }
    
    func saveImage() {
        guard let selectedImage = selectedImage else { return }
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else { return }

        let storage = Storage.storage()
        let storageRef = storage.reference()

        // Create a unique path for the image in Firebase Storage
        let imageName = "\(String(describing: Auth.auth().currentUser?.uid)).jpg"
        let imageRef = storageRef.child("profileImages/\(imageName)")

        // Upload the image data to Firebase Storage
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            // Get the download URL for the uploaded image
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }

                if let downloadURL = url {
                    // Update the profilePicURL with the download URL
                    self.profilePicURL = downloadURL
                    print("Image uploaded successfully. Download URL: \(downloadURL)")
                }
            }
        }
    }
    
    func save(){
        authenticate()
        updateDisplayName(firstName: firstNameInput, lastName: lastNameInput)
    }
    
    func profileUpdateMessage() -> Text {
        if isChangingEmail {
            return Text("Enter new email:")
        } else {
            return Text("Enter new password:")
        }
    }
    
    private func sendPasswordResetEmail(username: String) {
        Auth.auth().sendPasswordReset(withEmail: username)
    }
    
    private func sendVerification(username: String) {
        Auth.auth().currentUser?.sendEmailVerification()
    }
    
    func updateEmail(newEmail: String) {
        let user = Auth.auth().currentUser
        
        user?.sendEmailVerification(beforeUpdatingEmail: newEmail){ error in
            if let error = error {
                alertMessage = "Error updating email: \(error.localizedDescription)"
                showAlert2 = true
            } else {
                alertMessage = "An email has been sent to your new email. Please verify to change your email."
                showAlert2 = true

            }
        }
    }
        
    func fetchUserData() {
        let db = Firestore.firestore()
        let userRef = db.document("user/\(Auth.auth().currentUser!.uid)")
        
        loadImage()
        isVerified = ((Auth.auth().currentUser?.isEmailVerified) != nil)
        email = Auth.auth().currentUser!.email ?? ""
        isLoggedOut = false
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                return
            }

            guard let document = document else {
                print("Document does not exist")
                return
            }

            if let fullName = document.data()?["fullName"] as? String {
                print("Full Name: \(fullName)")
                displayName = fullName
            } else {
                print("Full Name not found or is not a string")
            }
        }
        
        print(userRef)
        
        notificationSetting = UserDefaults().bool(forKey: "sendNotif")
        
        trustScore = reportManager.calculateUserTrustScore()
    }
    
    func updateDisplayName(firstName: String, lastName: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        writeData(fullName: firstName + " " + lastName, uid: uid)
    }
    
    func writeData(fullName: String, uid: String) {
        let docRef = database.document("user/\(uid)")

        let data: [String: Any] = [
            "fullName": fullName
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

struct ItemView: View {
    @Binding var report: Report

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(report.articleID)")
                    .font(.headline)
            }
        }
        .padding()
    }
}

#Preview {
    Profile()
}
