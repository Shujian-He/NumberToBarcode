//
//  ContentView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 03/01/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Generator", systemImage: "barcode") {
                GeneratorView()
            }
//            .badge(2)

            Tab("Scanner", systemImage: "barcode.viewfinder") {
                ScannerView()
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        } // stupid way to disable all animation
    }
}

#Preview {
    ContentView()
}
