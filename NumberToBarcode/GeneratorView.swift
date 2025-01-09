//
//  GeneratorView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 09/01/2025.
//

import SwiftUI

// stupid function to dismiss keyboard
// it's weird that Apple doesn't provide a native way to do that in 2024
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

struct GeneratorView: View {
    @State private var userInputText: String = ""
    @State private var isGenerated: Bool = false
    @FocusState private var isFocused: Bool
    @State private var selectedBarcodeType: BarcodeType = .code128
    @State private var isReadColor = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Barcode Generator")
                .font(.system(size: 35, weight: .black, design: .default))
            
            Text("Enter barcode text below (a-zA-Z0-9)")
                .font(.headline)
                .onTapGesture {
                    hideKeyboard()
                }
                
            TextField("Type your text", text: $userInputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.headline)
                .focused($isFocused)
                .onChange(of: isFocused) {
                    if isFocused {
                        isGenerated = false
                    }
                }
                .onChange(of: userInputText) {
                    // Validate and filter input to allow only ASCII characters
                    let filtered = userInputText.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
//                    let filtered = userInputText.filter { $0.isASCII && ($0.isLetter || $0.isNumber) }
//                    if filtered != userInputText {
//                        userInputText = ""
//                    } else {
//                        userInputText = filtered
//                    }
                    userInputText = filtered
                }
            
            Picker("Select Barcode Type", selection: $selectedBarcodeType) {
                Text("Code128").tag(BarcodeType.code128)
                Text("QR Code").tag(BarcodeType.qr)
                Text("Aztec").tag(BarcodeType.aztec)
                Text("PDF417").tag(BarcodeType.pdf417)
//                Text("Data Matrix").tag(BarcodeType.dataMatrix) // not yet supported!!!!!
            }
                .pickerStyle(.segmented)
            
            Toggle("Follow system color", isOn: $isReadColor)
            
            Button("Generate") {
                isGenerated = true
                isFocused = false
            }
                .padding()
                .font(.title)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .drawingGroup() // disable stupid animation
            
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                if isGenerated {
                    if !isReadColor {
                        BarcodeView(inputText: userInputText, barcodeType: selectedBarcodeType)
                        
                    } else {
                        BarcodeView(inputText: userInputText, barcodeType: selectedBarcodeType, colorScheme: colorScheme)
                    }
                }
                Spacer()
            }
        }
            .padding() // padding for whole VStack
    }
}

#Preview {
    GeneratorView()
}
