//
//  ForgotPassword.swift
//  Hoax Hunter
//
//  Created by Henry Bonomolo on 4/7/24.
//

import SwiftUI
import Firebase

struct ForgotPassword: View {
    @State private var username: String = ""
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
            
            TextField("Email", text: $username)
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

            Button(action: {
                sendPasswordResetEmail()
            }) {
                Text("Reset Password")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)
            
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
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func sendPasswordResetEmail() {
        Auth.auth().sendPasswordReset(withEmail: username) { error in
            if let error = error {
                self.alertMessage = "Password reset error: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertMessage = "Password reset email sent successfully!"
                self.showAlert = true
            }
        }
    }
}

#Preview {
    ForgotPassword(hasShownSheet: Binding<Bool>.constant(true))
}
