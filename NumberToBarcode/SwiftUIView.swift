//
//  GeneratorView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 09/01/2025.
//

import SwiftUI


struct TestView: View {
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

            
            

            
            Spacer()

        }
        .padding(15)

    }
}

#Preview {
    TestView()
}
