//
//  ContentView.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI

struct ContentView: View {
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
    
    
    func connectToVPN() {
        // Get the path to the shell script in the app bundle
        if let scriptPath = Bundle.main.path(forResource: "hello", ofType: "sh") {
            // Create a Process to run the script
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash") // Specify the shell
            process.arguments = [scriptPath] // Path to the script

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
            } catch {
                print("Failed to run script: \(error)")
            }
        } else {
            print("Shell script not found.")
        }
    }
}
    
    func disconnectFromVPN(){
        print("Disconnected from VPN")
    }




#Preview {
    ContentView()
}
