//
//  ErrorView.swift
//  vpn-indicator
//
//  Created by Sebastian Macias on 16/12/25.
//

import SwiftUI

struct ErrorView: View {
    @Binding var errorMessage: String
    @Environment(\.dismissWindow) var dismiss // To close the window

    var body: some View {
        VStack {
            Text("Error")
                .font(.title)
                .padding(.bottom, 5)

            Text(errorMessage)
                .font(.body)
                .padding()

            Button("OK") {
                dismiss() // Close the window when the button is pressed
            }
            .padding(.top, 5)
            .buttonStyle(.bordered)
        }
    }
}
