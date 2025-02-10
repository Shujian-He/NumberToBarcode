//
//  OnlineBarcodeView.swift
//  NumberToBarcode
//
//  Created by Shujian He on 10/02/2025.
//

import SwiftUI
import UIKit

func fetchBarcodeImage(value: String, type: String, completion: @escaping (UIImage?) -> Void) {
    let baseUrl = "http://192.168.31.31:12138/data"  // Replace with your actual API URL
    let urlString = "\(baseUrl)?value=\(value)&type=\(type)"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil, let image = UIImage(data: data) else {
            print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        
        DispatchQueue.main.async {
            completion(image)
        }
    }
    
    task.resume()
}

enum onlineBarcodeType {
    case ean8
    case ean13
    
    var string: String {
        switch self {
            case .ean8: return "ean8"
            case .ean13: return "ean13"
        }
    }
}

struct OnlineBarcodeView: View {
    @Binding var barcodeValue: String
    @Binding var barcodeType: onlineBarcodeType
    @State private var barcodeImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let barcodeImage = barcodeImage {
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
                Text("Error fetching barcode")
            }
        }
        .onAppear {
            fetchBarcode()
        }
        .onChange(of: barcodeValue) {
            fetchBarcode()
        }
        .onChange(of: barcodeType) {
            fetchBarcode()
        }
    }
    
    private func fetchBarcode() {
        fetchBarcodeImage(value: barcodeValue, type: barcodeType.string) { image in
            if let fetchedImage = image {
                DispatchQueue.main.async {
                    self.barcodeImage = fetchedImage
                }
            } else {
                self.barcodeImage = nil
            }
        }
    }
}

#Preview {
    OnlineBarcodeView(barcodeValue: .constant("1235678"), barcodeType: .constant(.ean8))
}
