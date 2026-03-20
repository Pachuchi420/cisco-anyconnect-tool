import SwiftUI

struct FormField: View {
    var label: String
    var fieldLabel : String?
    var isSecure: Bool
    @Binding var text: String
    var customButton : Bool
    var buttonLabel: String?
    var buttonIcon : String
    var buttonAction: () -> Void = {}   // ← DEFAULT
    
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: -10) {
            HStack(alignment:.center, spacing: -10){
                Text(label)
                    .padding(.horizontal)
                
                if customButton{
                    customButtonCreator(text:buttonLabel,
                                        icon:buttonIcon,
                                        customAction: buttonAction)
                }
            }
            
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


func customButtonCreator(
    text: String?,
    icon: String?,
    customAction: @escaping () -> Void = {}
) -> some View {
    Button {
        customAction()
    } label: {
        if let text, !text.isEmpty {
            Label(text, systemImage: icon ?? "")
        } else if let icon {
            Image(systemName: icon)
        }
    }
    .buttonStyle(.automatic)
    .cornerRadius(100)
    .pointerStyle(.link)
}
