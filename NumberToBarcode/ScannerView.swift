//
//  ScannerView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 09/01/2025.
//
//  Based on the insights from https://www.hackingwithswift.com/books/ios-swiftui/scanning-qr-codes-with-swiftui
//

import SwiftUI
import CodeScanner

struct ScannerView: View {
    @State private var isPresentingScanner = false
    @State private var isHiddenResult = true
    @State private var scannedCode: String?
    @State private var userInputText: String = ""
    @State private var isCopied = false
    let pasteboard = UIPasteboard.general
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isPresentingScanner = false
        isHiddenResult = false
        switch result {
        case .success(let result):
            scannedCode = result.string
        case .failure(let error):
            scannedCode = "ERROR: \(error)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Barcode Scanner")
                .font(.system(size: 35, weight: .black, design: .default))
            
            Text("Tap the button to scan a code")
                .font(.headline)

            Button("Scan") {
                isPresentingScanner = true
                isHiddenResult = true
                isCopied = false
            }
                .padding()
                .font(.title)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .drawingGroup() // disable stupid animation

            Spacer()
            
            if !isHiddenResult {
                Text("You scanned: ")
                    .font(.headline)
                Text("\(scannedCode ?? "")")
                    .textSelection(.enabled)
                HStack() {
                    Button("Copy Result") {
                        pasteboard.string = scannedCode
                        isCopied = true
                    }
                    if isCopied {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.headline)
                        Text("Text Copied")
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                }
            }
            
            Spacer()

            // It's so funny that I have to add this and hide to keep that hilarious padding
            TextField("", text: $userInputText)
                .hidden()
            
        }
        .padding()
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.code128, .qr, .aztec, .pdf417], showViewfinder: true, simulatedData: "https://github.com/twostraws/CodeScanner", completion: handleScan)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ScannerView()
}
