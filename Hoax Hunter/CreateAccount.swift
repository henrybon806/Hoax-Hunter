//
//  CreateAccount.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/7/24.
//

import SwiftUI
import Firebase

struct CreateAccount: View {
    @State private var email: String = ""
    @State private var title: String = "Error"
    @State private var password: String = ""
    @State private var reenterpassword: String = ""
    @State private var name: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var hasShownSheet: Bool

    var body: some View {
        VStack {
            Text("Hoax Hunter")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            
            Image("world")
                .resizable()
                .frame(width: 125,height: 125)
                .padding(.bottom, 30)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 20)
                .toolbar {
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
            
            TextField("Name", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 30)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 30)
            
            SecureField("Re-Enter Password", text: $reenterpassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 30)
            
            Button(action: {
                createAccount()
            }) {
                Text("Create Account")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom, 20)
            }
                HStack {
                    Spacer()
                    NavigationLink(destination: Login(hasShownSheet: $hasShownSheet)) {
                        Text("Return to login")
                            .foregroundColor(.blue)
                    }
                    .transition(.identity)
                    Spacer()
                }
                .navigationBarHidden(true)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text(title), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func createAccount() {
            guard password.count >= 8 else {
                showAlert(message: "Password must be at least 8 characters long.")
                return
            }
        
            guard name.count > 0 else {
                showAlert(message: "Please enter a valid name.")
                return
            }
        
            guard password == reenterpassword else {
                showAlert(message: "Passwords do not match.")
                return
            }

            guard email.isValidEmail() else {
                showAlert(message: "Please enter a valid email.")
                return
            }


            Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
                if let error = error {
                    showAlert(message: error.localizedDescription)
                    return
                }

                guard let methods = methods else {
                    // No existing account found for this email, proceed with account creation
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            showAlert(message: error.localizedDescription)
                        } else {
                            writeData(fullName: name, uid: authResult!.user.uid)
                            showAlert(message: "You account has been created. Return to the login page to continue.", title: "Finished")
                            print("Account created successfully!")
                        }
                    }
                    return
                }

                if methods.isEmpty {
                    // No existing account found for this email, proceed with account creation
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            showAlert(message: error.localizedDescription)
                        } else {
                            // Account creation successful, you can navigate to the next screen or perform any other action
                            print("Account created successfully!")
                        }
                    }
                } else {
                    showAlert(message: "An account with this email already exists.")
                }
            }
        }

        private func showAlert(message: String) {
            self.showAlert = true
            self.alertMessage = message
        }
    
        private func showAlert(message: String, title: String) {
            self.showAlert = true
            self.alertMessage = message
            self.title = title
        }
    
    func writeData(fullName: String, uid: String) {
        let docRef = Firestore.firestore().document("user/\(uid)")

          let data: [String: Any] = [
              "fullName": fullName
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

extension String {
    func isValidEmail() -> Bool {
        // Regular expression for email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

#Preview {
    CreateAccount(hasShownSheet: Binding<Bool>.constant(true))
}
