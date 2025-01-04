//
//  BarcodeView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 03/01/2025.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

// Enum for supported barcode types
enum BarcodeType {
    case code128
    case qr
    case aztec
    case pdf417

    // Associated CIFilter for each barcode type
    var filter: CIFilter {
        switch self {
        case .code128:
            return CIFilter.code128BarcodeGenerator()
        case .qr:
            return CIFilter.qrCodeGenerator()
        case .aztec:
            return CIFilter.aztecCodeGenerator()
        case .pdf417:
            return CIFilter.pdf417BarcodeGenerator()
        }
    }
}

struct BarcodeGenerator {
    let context = CIContext()

    // Function to generate barcodes
    func generateBarcode(text: String, type: BarcodeType = .code128, color: ColorScheme = .light) -> Image {
        
        if text.isEmpty {
            return Image(systemName: "xmark.circle")
        }
        
        let filter = type.filter

        filter.setValue(Data(text.utf8), forKey: "inputMessage")

        // Ensure the output image is available
        guard let outputImage = filter.outputImage else {
            return Image(systemName: "xmark.circle") // Fallback if generation fails
        }

        // Scale the image to make it higher resolution
        let scaleX: CGFloat = 10.0 // Horizontal scale
        let scaleY: CGFloat = 10.0 // Vertical scale
        var transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Optionally invert colors for dark mode
        if color == .dark {
            let invertFilter = CIFilter.colorInvert()
            invertFilter.inputImage = transformedImage
            if let invertedImage = invertFilter.outputImage {
                transformedImage = invertedImage
            }
        }
        
        // Render the high-resolution image
        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            return Image(decorative: cgImage, scale: 1.0, orientation: .up) // Return SwiftUI.Image
        }

        return Image(systemName: "xmark.circle") // Fallback if rendering fails
    }
}

struct BarcodeView: View {
    var inputText: String
    var barcodeGenerator = BarcodeGenerator()
    var barcodeType: BarcodeType = .code128
    var colorScheme: ColorScheme = .light

    var body: some View {
        VStack(spacing: 0) {
            barcodeGenerator.generateBarcode(text: inputText, type: barcodeType, color: colorScheme)
                .resizable()
                .scaledToFit()

            Text(inputText.isEmpty ? "EMPTY INPUT" : inputText)
        }
        .padding()
    }
    
}

#Preview {
    BarcodeView(inputText: "76457616829459", barcodeType: .pdf417)
}
