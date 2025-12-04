//
//  AddAlmostViewModel.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftUI
import CoreLocation
import PhotosUI
import Combine

@MainActor
class AddAlmostViewModel: ObservableObject {
    @Published var selectedCategory: Category = .other
    @Published var closenessPercentage: Double = 50
    @Published var selectedObstacle: Obstacle = .other
    @Published var text: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var selectedVideo: PhotosPickerItem?
    @Published var selectedVideoURL: URL?
    @Published var videoThumbnail: UIImage?
    @Published var useLocation: Bool = true
    @Published var location: CLLocationCoordinate2D?
    @Published var selectedDate: Date = Date()
    
    var isFormValid: Bool {
        closenessPercentage >= Double(Constants.minClosenessPercentage) &&
        closenessPercentage <= Double(Constants.maxClosenessPercentage)
    }
    
    var textCharacterCount: Int {
        text.count
    }
    
    var canSave: Bool {
        isFormValid && textCharacterCount <= Constants.maxTextLength
    }
    
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else {
            selectedImage = nil
            return
        }
        
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
            selectedVideo = nil
            selectedVideoURL = nil
            videoThumbnail = nil
        }
    }
    
    func loadVideo(from item: PhotosPickerItem?) async {
        guard let item = item else {
            selectedVideo = nil
            selectedVideoURL = nil
            videoThumbnail = nil
            return
        }
        
        if let movie = try? await item.loadTransferable(type: Movie.self) {
            selectedVideoURL = movie.url
            selectedImage = nil
            selectedPhoto = nil
            
            // Generate thumbnail
            if let thumbnail = await MediaService.shared.generateThumbnail(for: movie.url) {
                videoThumbnail = thumbnail
            }
        }
    }
    
    func saveMedia() -> URL? {
        // Save video if available
        if let videoURL = selectedVideoURL {
            return MediaService.shared.saveVideo(from: videoURL)
        }
        
        // Save image if available
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
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
    
    var hasMedia: Bool {
        selectedImage != nil || selectedVideoURL != nil
    }
}

// Helper struct for video transfer
struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Movie(url: copy)
        }
    }
}

