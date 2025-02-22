//
//  GeneratorView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 09/01/2025.
//
//  Based on the insights from https://www.appcoda.com/swiftui-barcode-generator/
//

import SwiftUI


// stupid function to dismiss keyboard
// it's weird that Apple doesn't provide a native way to do that in 2024
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// stupid function to show clear button in a text field
func showClearButton() {
    UITextField.appearance().clearButtonMode = .whileEditing
}

struct GeneratorView: View {
    @State private var userInputText: String = ""
    @State private var isGenerated: Bool = false
    @FocusState private var isFocused: Bool
    @State private var selectedBarcodeType: BarcodeType = .code128
    @State private var selectedOnlineBarcodeType: OnlineBarcodeType = .ean13
    @State private var isReadColor = false
    @State private var isUseOnlineImage = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Barcode Generator")
                .font(.system(size: 35, weight: .black, design: .default))
            
            Text("Enter barcode text below (ASCII only)")
                .font(.headline)
                .onTapGesture(perform: hideKeyboard)
                
            TextField("Type your text", text: $userInputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.headline)
                .focused($isFocused)
                .onAppear(perform: showClearButton)
                .onChange(of: isFocused) {
                    if isFocused {
                        isGenerated = false
                    }
                }
                .onChange(of: userInputText) {
                    // Validate and filter input to allow only ASCII characters
                    let filtered = userInputText.replacingOccurrences(of: "[^\\x20-\\x7E]", with: "", options: .regularExpression)
                    userInputText = filtered
                }
            
            Toggle("Use API", isOn: $isUseOnlineImage)
            
            if isUseOnlineImage {
                Picker("Select Barcode Type", selection: $selectedOnlineBarcodeType) {
                    Text("EAN8").tag(OnlineBarcodeType.ean8)
                    Text("EAN13").tag(OnlineBarcodeType.ean13)
                }
                    .pickerStyle(.segmented)
                
            } else {
                Picker("Select Barcode Type", selection: $selectedBarcodeType) {
                    Text("Code128").tag(BarcodeType.code128)
                    Text("QR Code").tag(BarcodeType.qr)
                    Text("Aztec").tag(BarcodeType.aztec)
                    Text("PDF417").tag(BarcodeType.pdf417)
    //                Text("Data Matrix").tag(BarcodeType.dataMatrix) // not yet supported!!!!!
                }
                    .pickerStyle(.segmented)
                
                Toggle("Follow system color", isOn: $isReadColor)
            }

            Button(action: {
                isGenerated = true
                isFocused = false
            }) {
                Text("Generate Barcode")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
                .drawingGroup() // disable stupid animation
            
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                if isGenerated {
                    if !isUseOnlineImage {
                        if !isReadColor {
                            BarcodeView(barcodeValue: userInputText, barcodeType: selectedBarcodeType)
                            
                        } else {
                            BarcodeView(barcodeValue: userInputText, barcodeType: selectedBarcodeType, colorScheme: colorScheme)
                        }
                    } else {
                        OnlineBarcodeView(barcodeValue: $userInputText, barcodeType: $selectedOnlineBarcodeType)
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
