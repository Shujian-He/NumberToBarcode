//
//  BarcodeView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 03/01/2025.
//

import UIKit
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
    
    // Generate a barcode SwiftUI Image
    func generateBarcodeImage(text: String, type: BarcodeType = .code128, color: ColorScheme = .light) -> Image? {
        guard let uiImage = generateBarcodeUIImage(text: text, type: type, color: color) else {
            return Image(systemName: "xmark.circle") // Fallback if generation fails
        }
        return Image(uiImage: uiImage)
    }
    
    // Generate a barcode UIImage
    func generateBarcodeUIImage(text: String, type: BarcodeType = .code128, color: ColorScheme = .light) -> UIImage? {
        
        if text.isEmpty {
            return nil // Fallback if text is empty
        }
        
        let filter = type.filter

        filter.setValue(Data(text.utf8), forKey: "inputMessage")

        // Ensure the output image is available
        guard let outputImage = filter.outputImage else {
            return nil // Fallback if generation fails
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
            return UIImage(cgImage: cgImage)
        }

        return nil // Fallback if generation fails
    }
}

struct BarcodeView: View {
    var inputText: String
    var barcodeGenerator = BarcodeGenerator()
    var barcodeType: BarcodeType = .code128
    var colorScheme: ColorScheme = .light

    var body: some View {
        VStack(spacing: 0) {
            if let barcodeImage = barcodeGenerator.generateBarcodeUIImage(text: inputText, type: barcodeType, color: colorScheme) {
                Image(uiImage: barcodeImage)
                    .resizable()
                    .scaledToFit()
                    .contextMenu { // Add context menu
                        Button(action: {
                            // stupid way to save image
                            // SwiftUI Image doesn't provide a way to save
                            // so needed to generate a UIImage first
                            // then show it in SwiftUI Image but save in UIImage
                            UIImageWriteToSavedPhotosAlbum(barcodeImage, nil, nil, nil)
                        }) {
                            Text("Save to Photos")
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
            } else {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
            }
            Text(inputText.isEmpty ? "EMPTY INPUT" : inputText)
        }
        .padding()
    }
}

#Preview {
    BarcodeView(inputText: "7123456789", barcodeType: .pdf417)
}
