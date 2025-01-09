//
//  BarcodeView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 03/01/2025.
//
//  Functions to generate barcodes are adapted from Apple Core Image Documentation at https://developer.apple.com/documentation/coreimage/cifilter/generator_filters

import UIKit
import SwiftUI
import CoreImage.CIFilterBuiltins

func code128Barcode(inputMessage: String) -> CIImage {
    let code128Barcode = CIFilter.code128BarcodeGenerator()
    code128Barcode.message = inputMessage.data(using: .ascii)!
//    code128Barcode.quietSpace = 5
//    code128Barcode.barcodeHeight = 20
    return code128Barcode.outputImage!
}

func aztecCode(inputMessage: String) -> CIImage {
    let aztecCodeGenerator = CIFilter.aztecCodeGenerator()
    aztecCodeGenerator.message = inputMessage.data(using: .ascii)!
//    aztecCodeGenerator.correctionLevel = 15
//    aztecCodeGenerator.compactStyle = 0
//    aztecCodeGenerator.layers = 10
    return aztecCodeGenerator.outputImage!
}

func qrCode(inputMessage: String) -> CIImage {
    let qrCodeGenerator = CIFilter.qrCodeGenerator()
    qrCodeGenerator.message = inputMessage.data(using: .ascii)!
//    qrCodeGenerator.correctionLevel = "H"
    return qrCodeGenerator.outputImage!
}

func pdf417Barcode(inputMessage: String) -> CIImage {
    let pdf417BarcodeGenerator = CIFilter.pdf417BarcodeGenerator()
    pdf417BarcodeGenerator.message = inputMessage.data(using: .ascii)!
//    pdf417BarcodeGenerator.minWidth = 56
//    pdf417BarcodeGenerator.maxWidth = 58
//    pdf417BarcodeGenerator.maxHeight = 283
//    pdf417BarcodeGenerator.minHeight = 13
//    pdf417BarcodeGenerator.dataColumns = 9
//    pdf417BarcodeGenerator.rows = 6
//    pdf417BarcodeGenerator.preferredAspectRatio = 0.0
//    pdf417BarcodeGenerator.compactionMode = 1
//    pdf417BarcodeGenerator.compactStyle = 1
//    pdf417BarcodeGenerator.correctionLevel = 0.01
//    pdf417BarcodeGenerator.alwaysSpecifyCompaction = 0
    return pdf417BarcodeGenerator.outputImage!
}

func dataMatrixCode(inputMessage: String) -> CIImage {
    let barcodeGenerator = CIFilter.barcodeGenerator()
    barcodeGenerator.barcodeDescriptor = CIDataMatrixCodeDescriptor(payload: inputMessage.data(using: .ascii)!, rowCount: 40, columnCount: 40, eccVersion: .v050)!
    return barcodeGenerator.outputImage ?? CIImage()
}

// Enum for supported barcode types
enum BarcodeType {
    case code128
    case qr
    case aztec
    case pdf417
    case dataMatrix

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
        case .dataMatrix:
            return CIFilter.barcodeGenerator()
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
        
//        let filter = type.filter
        // compromise that filter is a CIFilter
        // you can't use filter.message = text.data(using: .ascii)!
//        filter.setValue(text.data(using: .ascii), forKey: "inputMessage")

        var outputImage: CIImage
        
        switch type {
        case .code128:
            outputImage = code128Barcode(inputMessage: text)
        case .qr:
            outputImage = qrCode(inputMessage: text)
        case .aztec:
            outputImage = aztecCode(inputMessage: text)
        case .pdf417:
            outputImage = pdf417Barcode(inputMessage: text)
        case .dataMatrix:
            outputImage = dataMatrixCode(inputMessage: text)
        }
    
        // Ensure the output image is available
//        guard let outputImage = filter.outputImage else {
//            return nil // Fallback if generation fails
//        }

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
    BarcodeView(inputText: "712", barcodeType: .pdf417)
}
