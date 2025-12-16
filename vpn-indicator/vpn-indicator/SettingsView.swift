//
//  SettingsView.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI
import KeychainSwift
import KeyboardShortcuts

struct SettingsView: View {

    @State private var vpnAddress: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var secret: String = ""
    @State private var showSuccessMessage: Bool = false  // State for showing the success message
    @State private var successMessage: String = ""  // Success message text
    
    private let keychain = KeychainSwift()
    
    
    var body: some View {
        
        VStack{
            VStack(
                alignment: .center,
                spacing: 0
            ){
                
                Text("User Data")
                    .font(.title)
                
                
                FormField(label: "VPN Address", fieldLabel: "Enter the server you want to connect to.", isSecure: false, text: $vpnAddress)
                FormField(label: "Username", fieldLabel: "Enter the username you use under your institution", isSecure: false, text: $username)
                FormField(label: "Password", fieldLabel: "Enter your password", isSecure: false, text: $password)
                FormField(label: "Secret", fieldLabel: "Enter the secret for your OTP", isSecure: true, text: $secret)
                
                // Success message display
                if showSuccessMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.headline)
                        .transition(.opacity)
                        .padding(.bottom)
                        .onAppear {
                            // Fade out the message after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSuccessMessage = false
                                }
                            }
                        }
                }
                
                Button("Save Data") {
                    saveData()
                }
                .padding()
                
            }
            Divider()
            
        }
       
        

    }
    
    
    func areFieldsEmpty() -> Bool {
        print(vpnAddress.isEmpty)
        print(vpnAddress)
        if vpnAddress.isEmpty || username.isEmpty || password.isEmpty || secret.isEmpty {
            return true
        }
        
        return false
    }
    
    func saveData(){
        if areFieldsEmpty() == false {
            UserDefaults.standard.set(vpnAddress, forKey: "vpnAddress")
            UserDefaults.standard.set(username, forKey: "username")

            // Save sensitive data to Keychain
            keychain.set(password, forKey: "password")
            keychain.set(secret, forKey: "secret")

            // Show success message with animation
            successMessage = "Data saved successfully!"
            withAnimation {
                showSuccessMessage = true
            }
        } else {
            successMessage = "Missing obligatory fields"
            showSuccessMessage = true
        }
        
        
       
    }
}

#Preview {
    SettingsView()
}
