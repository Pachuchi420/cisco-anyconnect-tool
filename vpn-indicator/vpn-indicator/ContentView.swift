//
//  ContentView.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI
import KeychainSwift

struct ContentView: View {
    @Binding var isConnected : Bool
    private let keychain = KeychainSwift()
    @State private var textInput : String = ""
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                connectToVPN()
            }) {Label("Connect", systemImage: "network")}
            
            Button(action: {
                disconnectFromVPN()
            }) {Label("Disconnect", systemImage: "network.slash")}
            
            
            
            Divider()
            
            Button(action: {
                openSettingsWindow()
            }) {Label("Settings", systemImage: "gear")}
            
        }
        .padding()
        
        
    }
    
    func openSettingsWindow(){
        NSApplication.shared.activate(ignoringOtherApps: true)
        openWindow(id: "settings-view")
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
            // Create a Process to run the script
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash") // Specify the shell
            process.arguments = [
                scriptPath,
                vpnAddress,
                username,
                password,
                secret
            ]
            
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
                
                if process.terminationStatus == 0 {
                    isConnected = true
                }
            } catch {
                print("Failed to run script: \(error)")
            }
        } else {
            print("Shell script not found.")
        }
    }
    
    
    func disconnectFromVPN() {
        if let scriptPath = Bundle.main.path(forResource: "dis_cisco", ofType: "sh") {
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
