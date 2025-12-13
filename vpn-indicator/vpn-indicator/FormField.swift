import SwiftUI

struct FormField: View {
    var label: String
    var fieldLabel : String?
    var isSecure: Bool
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: -10) {
            Text(label)
                .padding(.horizontal)
            
            if isSecure {
                SecureField(fieldLabel ?? "", text: $text)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                TextField(fieldLabel ?? "", text: $text)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}
