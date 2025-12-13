//
//  vpn_indicatorApp.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 12/12/25.
//

import SwiftUI

@main
struct vpn_indicatorApp: App {
    @State private var showSettings = false
    
    
    var body: some Scene {
       MenuBarExtra(
        "Menu Bar Example",
        systemImage: "characters.uppercase"
       ) {
           ContentView()
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
       }
       .menuBarExtraStyle(.window)
        
        
        WindowGroup(id: "settings-view") {
                    SettingsView()
        }
    }
    
    
   
}
