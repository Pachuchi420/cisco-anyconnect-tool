//
//  vpn_indicatorApp.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI

@main
struct vpn_indicatorApp: App {
    @State private var isConnected = false
    @State private var showSettings = false

    

    var body: some Scene {
       MenuBarExtra {
           ContentView(isConnected: $isConnected)
               .overlay(alignment: .topTrailing){
                   Button(
                        "Quit",
                        systemImage: "xmark.circle.fill"
                   ){
                       
                       NSApp.terminate(nil)
                   }
                   .labelStyle(.iconOnly)
                   .buttonStyle(.plain)
                   .padding(6)
               }
               .frame(width: 300, height: 180)
       } label: {
           MenuBarIcon(isConnected: isConnected)
       }.menuBarExtraStyle(.window)
        
        WindowGroup(id: "settings-view") {
                    SettingsView()
        }
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

