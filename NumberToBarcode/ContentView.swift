//
//  ContentView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 03/01/2025.
//

import SwiftUI

struct ContentView: View {
    
    // stupid function to dismiss keyboard
    // it's weird that Apple doesn't provide a native way to do that in 2024
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @State private var userInputText: String = ""
    @State private var isGenerated: Bool = false
    @FocusState private var isFocused: Bool
    @State private var selectedBarcodeType: BarcodeType = .code128
    @State private var isReadColor = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading) {

            Text("Barcode Generator")
                .padding(.bottom, 10)
                .font(.system(size: 35, weight: .black, design: .default))
            
            Text("Enter barcode text below (ASCII only)")
                .padding(.bottom, 10)
                .font(.headline)
                .onTapGesture {
                    hideKeyboard()
                }
                
            TextField("Type your text", text: $userInputText)
                .padding(.bottom, 10)
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
                    let filtered = userInputText.filter { $0.isASCII }
                    userInputText = filtered
                }
            
            Picker("Select Barcode Type", selection: $selectedBarcodeType) {
                Text("Code128").tag(BarcodeType.code128)
                Text("QR Code").tag(BarcodeType.qr)
                Text("Aztec").tag(BarcodeType.aztec)
                Text("PDF417").tag(BarcodeType.pdf417)
            }
                .padding(.bottom, 10)
                .pickerStyle(SegmentedPickerStyle())
            
            Toggle("Follow system color", isOn: $isReadColor)
                .padding(.bottom, 10)
            
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
            
            if isGenerated {
                if !isReadColor {
                    BarcodeView(inputText: userInputText, barcodeType: selectedBarcodeType)
                        .padding()
                } else {
                    BarcodeView(inputText: userInputText, barcodeType: selectedBarcodeType, colorScheme: colorScheme)
                        .padding()
                }
            }
        }
        .padding()
        .transaction { transaction in
            transaction.animation = nil
        } // stupid way to disable all animation
    }
}

#Preview {
    ContentView()
}
