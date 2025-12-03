//
//  AddAlmostView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation

struct AddAlmostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddAlmostViewModel()
    @StateObject private var locationService = LocationService.shared
    
    let context: ModelContext
    
    var body: some View {
        NavigationStack {
            Form {
                // Required Fields
                Section("Required") {
                    // Category Picker
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            HStack {
                                CategoryIconView(category: category)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    
                    // Closeness Slider
                    ClosenessSlider(
                        value: $viewModel.closenessPercentage,
                        range: Double(Constants.minClosenessPercentage)...Double(Constants.maxClosenessPercentage)
                    )
                    
                    // Obstacle Picker
                    Picker("What stopped you?", selection: $viewModel.selectedObstacle) {
                        ForEach(Obstacle.allCases, id: \.self) { obstacle in
                            HStack {
                                Image(systemName: obstacle.iconName)
                                Text(obstacle.displayName)
                            }
                            .tag(obstacle)
                        }
                    }
                }
                
                // Optional Fields
                Section("Optional") {
                    // Text Input
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Tell your story...", text: $viewModel.text, axis: .vertical)
                            .lineLimit(3...6)
                        
                        HStack {
                            Spacer()
                            Text("\(viewModel.textCharacterCount)/\(Constants.maxTextLength)")
                                .font(.caption)
                                .foregroundColor(viewModel.textCharacterCount > Constants.maxTextLength ? .red : .secondary)
                        }
                    }
                    
                    // Photo/Video Picker
                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add Photo")
                        }
                    }
                    .onChange(of: viewModel.selectedPhoto) { oldValue, newValue in
                        Task {
                            await viewModel.loadImage(from: newValue)
                        }
                    }
                    
                    PhotosPicker(selection: $viewModel.selectedVideo, matching: .videos) {
                        HStack {
                            Image(systemName: "video")
                            Text("Add Video")
                        }
                    }
                    .onChange(of: viewModel.selectedVideo) { oldValue, newValue in
                        Task {
                            await viewModel.loadVideo(from: newValue)
                        }
                    }
                    
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                    
                    if let thumbnail = viewModel.videoThumbnail, let videoURL = viewModel.selectedVideoURL {
                        ZStack {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Location Toggle
                    Toggle("Use Location", isOn: $viewModel.useLocation)
                        .onChange(of: viewModel.useLocation) { oldValue, newValue in
                            if newValue {
                                locationService.requestLocation()
                            }
                        }
                    
                    if viewModel.useLocation {
                        if let location = locationService.currentLocation {
                            Text("Location: \(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Getting location...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Date Picker
                    DatePicker("Date & Time", selection: $viewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Almost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMoment()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                if viewModel.useLocation {
                    locationService.requestLocation()
                }
            }
            .onChange(of: locationString(from: locationService.currentLocation)) { oldValue, newValue in
                if let location = locationService.currentLocation {
                    viewModel.location = location
                }
            }
        }
    }
    
    private func locationString(from location: CLLocationCoordinate2D?) -> String {
        guard let location = location else { return "" }
        return "\(location.latitude),\(location.longitude)"
    }
    
    private func saveMoment() {
        let mediaURL = viewModel.saveMedia()
        
        let isVictory = Int(viewModel.closenessPercentage) == 100
        
        let moment = AlmostMoment(
            category: viewModel.selectedCategory,
            closenessPercentage: Int(viewModel.closenessPercentage),
            obstacle: viewModel.selectedObstacle,
            text: viewModel.text.isEmpty ? nil : viewModel.text,
            mediaURL: mediaURL,
            location: viewModel.useLocation ? viewModel.location : nil,
            timestamp: viewModel.selectedDate,
            isVictory: isVictory
        )
        
        context.insert(moment)
        
        do {
            try context.save()
            AchievementManager.shared.checkAchievements(context: context)
            dismiss()
        } catch {
            print("Failed to save moment: \(error)")
        }
    }
}

