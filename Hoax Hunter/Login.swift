//
//  Login.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/7/24.
//

import SwiftUI
import Firebase
import LocalAuthentication

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var hasShownSheet: Bool
    @State private var isAuthenticated = false
    @State private var rememberLogin = false
    
    var body: some View {
        NavigationStack{
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
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.bottom, 30)
                
                Button(action: {
                        signIn()
                    }) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .padding(.bottom, 20)

                    NavigationLink(
                        destination: StartView(hasShownSheet: $hasShownSheet),
                        isActive: $isAuthenticated,
                        label: { EmptyView() }
                    )
                    .hidden()
                    .transition(.identity)
                
                HStack{
                    if rememberLogin{
                        Button(action: {
                            authenticateWithFaceID()
                        }) {
                            Image(systemName: "faceid")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .hidden()
                    }
                    else{
                        Button(action: {
                            // Add Face ID logic here
                        }) {
                            Image(systemName: "faceid")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .hidden()
                    }

                    Spacer()

                    Toggle("Remember Login", isOn: $rememberLogin)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        //.padding()
                        .padding(.leading, 100)
                    Spacer()
                }
                .padding(.bottom, 10)
                
                HStack {
                    Spacer()
                    NavigationLink(destination: ForgotPassword(hasShownSheet: $hasShownSheet)){
                        Text("Forgot Password?")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    NavigationLink(destination: CreateAccount(hasShownSheet: $hasShownSheet)){
                        Text("Create Account")
                            .foregroundColor(.blue)
                    }
                    .transition(.identity)
                    Spacer()
                }
                .navigationBarHidden(true)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            rememberLogin = (UserDefaults.standard.string(forKey: "rememberLogin") != nil)
           if rememberLogin {
               if let storedEmail = UserDefaults.standard.string(forKey: "storedEmail"),
                  let storedPassword = UserDefaults.standard.string(forKey: "storedPassword") {
                   email = storedEmail
                   password = storedPassword
                   signIn()
               }
           }
       }
        .navigationViewStyle(.stack)
    }
    
    private func signIn() {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.alertMessage = "Authentication error: \(error.localizedDescription)"
                    self.showAlert = true
                } else {
                    // Authentication successful, set isAuthenticated to true to trigger navigation
                    self.isAuthenticated = true
                    
                    if rememberLogin {
                        UserDefaults.standard.set(email, forKey: "storedEmail")
                        UserDefaults.standard.set(password, forKey: "storedPassword")
                        UserDefaults.standard.set(rememberLogin, forKey: "rememberLogin")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "storedEmail")
                        UserDefaults.standard.removeObject(forKey: "storedPassword")
                        UserDefaults.standard.removeObject(forKey: "rememberLogin")
                    }
                }
            }
        }
    
    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to log in"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful, proceed with sign in
                        if let storedEmail = UserDefaults.standard.string(forKey: "storedEmail"),
                               let storedPassword = UserDefaults.standard.string(forKey: "storedPassword") {
                                email = storedEmail
                                password = storedPassword
                                signIn()
                            } else {
                                self.alertMessage = "Stored email or password not found"
                                self.showAlert = true
                            }
                    } else {
                        // Authentication failed
                        self.alertMessage = "Face ID authentication failed"
                        self.showAlert = true
                    }
                }
            }
        } else {
            // Face ID not available, show error
            self.alertMessage = "Face ID not available"
            self.showAlert = true
        }
    }
}

#Preview {
    Login(hasShownSheet: Binding<Bool>.constant(true))
}
