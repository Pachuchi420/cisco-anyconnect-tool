//
//  ContentView.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI
import KeychainSwift
import SwiftOTP

struct ContentView: View {
    @Binding var isConnected : Bool
    @Binding var errorMessage : String
    private let keychain = KeychainSwift()
    @State private var textInput : String = ""
    @Environment(\.openWindow) var openWindow
    @State private var lastClickTime: Date? = nil
    @State var connectButtonDisabled : Bool = false
    @State var disconnectButtonDisabled : Bool = true
    
    @Environment(\.openSettings) private var openSettings
    
        
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            
            HStack(spacing: 0){
                Text("Status : ")
                isConnected ? Text("Connected").foregroundColor(.green) : Text("Not Connected").foregroundColor(.red)
            }
            
            Divider()
            
            
            Button(action: {
                let currentTime = Date()
                if let lastClickTime = lastClickTime, currentTime.timeIntervalSince(lastClickTime) < 7 {
                        // If clicked within 2 seconds, ignore the click
                        return
                }
                lastClickTime = currentTime
                connectButtonDisabled = true
                connectToVPN()
            }) {Label("Connect", systemImage: "network")}
                .buttonStyle(.borderedProminent)
                .pointerStyle(.link)
                .disabled(connectButtonDisabled)
            
            Button(action: {
                disconnectFromVPN()
            }) {Label("Disconnect", systemImage: "network.slash")}
                .buttonStyle(.borderedProminent)
                .pointerStyle(.link)
                .disabled(disconnectButtonDisabled)
            
        
            
            
            Divider()
            
            Button(action: {
                openSettings()
            }) {Label("Settings", systemImage: "gear")}
                .pointerStyle(.link)
            
            
            Button(
                 "Quit App",
                 systemImage: "xmark.circle.fill"
            ){
                disconnectFromVPN()
                NSApp.terminate(nil)
            }
            .pointerStyle(.link)
            
        }
        .padding()
        
        
        
    }
    

    
    
    func openErrorWindow(errorMessage : String){
        NSApplication.shared.activate(ignoringOtherApps: true)
        openWindow(id: "error-view")
        self.errorMessage = errorMessage
        
    }
    
    
    
    func getCredentials() -> (vpnAddress: String?, username: String?, password: String?, secret: String?) {
        let vpnAddress = UserDefaults.standard.string(forKey: "vpnAddress")
        let username = UserDefaults.standard.string(forKey: "username")
        let password = keychain.get("password")
        let secret = keychain.get("secret")
        return (vpnAddress, username, password, secret)
    }
    

    
    
    func connectToVPN() {
        let (vpnAddress, username, password, secret) = getCredentials()
        var code = ""
        guard
            let vpnAddress,
            let username,
            let password,
            let secret
        else {
            print("Missing credentials")
            return
        }
        
        
        if let scriptPath = Bundle.main.path(forResource: "cisco", ofType: "sh") {
            
            guard let data = base32DecodeToData(secret) else {return}
            
            if let totp = TOTP(secret: data){
                if let result = totp.generate(time:Date()){
                    code = result
                    print("Your code \(code)")
                }
                
            }
            
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash") // Specify the shell
            process.arguments = [
                scriptPath,
                vpnAddress,
                username,
                password,
                code
            ]
            
                        
         
            // Create a Pipe to capture output
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            // Launch the process
            do {
                
                print("Running script '\(scriptPath)' with arguments \n -\(vpnAddress) \n-\(username) \n-\(password) \n-\(code)" )
                try process.run()
                
                // Read the output
                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: .utf8) {
                    print("Script output: \(output)")
                    
                    let errorArray : [String] = [
                   "The VPN connection failed due to unsuccessful domain name resolution.",
                   "Login failed.",
                   "Connect capability is unavailable. Another Cisco Secure Client application acquired it."
                   ]
                    
                    if output.contains(errorArray[0]){
                        print(errorArray[0] + " Please check you wrote a correct VPN server.")
                        openErrorWindow(errorMessage: errorArray[0] + " Please check you wrote a correct VPN server.")
                        isConnected = false
                        connectButtonDisabled = false
                        disconnectButtonDisabled = true
                        
                    } else if output.contains(errorArray[1]){
                        print(errorArray[1] + " Try again, your OTP might've been generated wrong, if this doesn't workt then your username, password or oauth secret are wrong.")
                        openErrorWindow(errorMessage: errorArray[1] + " Your username, password or oauth secret are wrong, please try again.")
                        isConnected = false
                        connectButtonDisabled = false
                        disconnectButtonDisabled = true
                        
                    } else if output.contains(errorArray[2]){
                        print(errorArray[1] + " Try closing any instances of Cisco AnyConnect")
                        openErrorWindow(errorMessage: errorArray[1] + " Try closing any instances of Cisco AnyConnect")
                        isConnected = false
                        connectButtonDisabled = false
                        disconnectButtonDisabled = true
                    } else {
                        connectButtonDisabled = true
                        disconnectButtonDisabled = false
                        isConnected = true
                        
                    }
                }
                
                
                // Wait for the process to finish
                process.waitUntilExit()
            } catch {
                print("Failed to run script: \(error)")
            }
        } else {
            print("Shell script not found under")
        }
    }
    
    
    func disconnectFromVPN() {
        if let scriptPath = Bundle.main.path(forResource: "dis_cisco", ofType: "sh") {
            disconnectButtonDisabled = true
            connectButtonDisabled = false
            // Create a Process to run the script
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash") // Specify the shell
            process.arguments = [scriptPath]
            
            // Create a Pipe to capture output
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            // Launch the process
            do {
                try process.run()
                
                // Read the output
                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: .utf8) {
                    print("Script output: \(output)")
                }
                
                // Wait for the process to finish
                process.waitUntilExit()
                isConnected = false
            } catch {
                print("Failed to run script: \(error)")
            }
        }
    }
    
    
}
