//
//  MediaService.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import UIKit
import AVFoundation

class MediaService {
    static let shared = MediaService()
    
    private init() {}
    
    func saveImage(_ image: UIImage) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    func saveVideo(from sourceURL: URL) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = UUID().uuidString + ".mov"
        let destinationURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Failed to save video: \(error)")
            return nil
        }
    }
    
    func loadImage(from url: URL) -> UIImage? {
        guard let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func generateThumbnail(for url: URL) async -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try await generator.image(at: .zero).image
            return UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate thumbnail: \(error)")
            return nil
        }
    }
    
    func deleteImage(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

