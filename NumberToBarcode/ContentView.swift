//
//  ContentView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 03/01/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var userInputText: String = ""
    @State private var isGenerated: Bool = false
    @FocusState private var isFocused: Bool
    @State private var selectedBarcodeType: BarcodeType = .code128 // Default type

    
    var body: some View {
        VStack(alignment: .leading) {

            Text("Barcode Generator")
                .padding(.bottom, 20)
                .font(.system(size: 40, weight: .black, design: .default))
            
            Text("Enter barcode text below (ASCII only)")
                .padding(.bottom, 20)
                .font(.headline)
                
            TextField("Type your text", text: $userInputText)
                .padding(.bottom, 20)
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
                .padding(.bottom, 20)
                .pickerStyle(SegmentedPickerStyle())
            
            
            Button("Generate") {
                isGenerated = true
                isFocused = false
            }
                .padding()
                .font(.title)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            
            Spacer()
            
            if isGenerated {
                BarcodeView(inputText: userInputText, barcodeType: selectedBarcodeType)
                    .padding()
                    .transaction { transaction in
                        transaction.animation = nil // Disable animations for this view
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
