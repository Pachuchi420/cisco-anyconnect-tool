//
//  vpn_indicatorApp.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI
import KeyboardShortcuts

@main
struct vpn_indicatorApp: App {
    @State private var isConnected = false
    @State private var errorMessage = ""
    
    
    
    

    var body: some Scene {
      
       MenuBarExtra {
           ContentView(isConnected: $isConnected, errorMessage: $errorMessage)
        } label: {
           MenuBarIcon(isConnected: isConnected)
       }.menuBarExtraStyle(.window)
        
        Settings(){
            SettingsView()
                .frame(width: 400, height: 420)
        }
        
        WindowGroup(id: "error-view") {
            ErrorView(errorMessage: $errorMessage)
        }.defaultSize(width: 10, height: 10).windowResizability(.contentMinSize)
    }
    
    
    
   
}

struct MenuBarIcon: View {
    let isConnected: Bool

    var body: some View {
        Image(isConnected ? "vpn_connected" : "vpn_disconnected")
            .renderingMode(.template)
            .foregroundStyle(.primary)
    }
}


