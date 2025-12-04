//
//  VictoriesView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData
import AVKit

struct VictoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<AlmostMoment> { $0.isVictory == true },
           sort: [SortDescriptor(\.timestamp, order: .reverse)])
    private var victories: [AlmostMoment]
    
    @State private var showVideoGenerator = false
    @State private var isGeneratingVideo = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !victories.isEmpty {
                        // Victories List
                        ForEach(victories) { victory in
                            NavigationLink(destination: AlmostDetailView(moment: victory, context: modelContext)) {
                                VictoryCardView(moment: victory)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "trophy")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Victories Yet")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Convert your 'almost' moments into victories to see them here!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 60)
                    }
                }
                .padding(.vertical)
            }
            .scrollContentBackground(.hidden)
            .withAppBackground()
            .navigationTitle("Victories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showVideoGenerator = true
                    }) {
                        Image(systemName: "video.fill")
                            .foregroundColor(.yellow)
                    }
                    .disabled(victories.isEmpty)
                }
            }
            .sheet(isPresented: $showVideoGenerator) {
                VideoGeneratorView(victories: victories, isGenerating: $isGeneratingVideo)
            }
        }
    }
}

struct VideoGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    let victories: [AlmostMoment]
    @Binding var isGenerating: Bool
    @State private var generatedVideoURL: URL?
    @State private var errorMessage: String?
    @State private var progress: Double = 0.0
    
    // Selection State
    @State private var selectedVictories: Set<UUID> = []
    @State private var filterMode: FilterMode = .all
    
    enum FilterMode: String, CaseIterable {
        case all = "All Time"
        case year = "This Year"
        case threeMonths = "3 Months"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isGenerating {
                    // Generation Progress View
                    VStack(spacing: 24) {
                        Spacer()
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                            .padding(.horizontal)
                        
                        Text("Generating your victory video... \(Int(progress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                } else if let videoURL = generatedVideoURL {
                    // Result View
                    VStack(spacing: 16) {
                        Text("Video generated successfully!")
                            .font(.headline)
                            .padding(.top)
                        
                        // Video Player
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .aspectRatio(1.0, contentMode: .fit) // Square aspect ratio
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                        ShareLink(item: videoURL) {
                            Label("Share Video", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Button("Create Another") {
                            generatedVideoURL = nil
                            progress = 0.0
                        }
                        .padding(.top)
                        
                        Spacer()
                    }
                } else {
                    // Selection View
                    VStack(spacing: 16) {
                        // Filter Buttons
                        Picker("Filter", selection: $filterMode) {
                            ForEach(FilterMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .onChange(of: filterMode) { _ in
                            applyFilter()
                        }
                        
                        // List of Victories to Select
                        List {
                            ForEach(victories) { victory in
                                HStack {
                                    Image(systemName: selectedVictories.contains(victory.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedVictories.contains(victory.id) ? .blue : .gray)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(victory.text ?? "Victory")
                                            .font(.headline)
                                            .lineLimit(1)
                                        Text(victory.timestamp, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: victory.categoryEnum.iconName)
                                        .foregroundColor(victory.categoryEnum.color)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    toggleSelection(for: victory)
                                }
                            }
                        }
                        .listStyle(.plain)
                        
                        // Generate Button
                        Button(action: {
                            generateVideo()
                        }) {
                            Text("Generate Video (\(selectedVictories.count))")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedVictories.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(selectedVictories.isEmpty)
                        .padding()
                    }
                }
            }
            .navigationTitle("New Year Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Initial selection (All)
                if selectedVictories.isEmpty {
                    applyFilter()
                }
            }
        }
    }
    
    private func applyFilter() {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredVictories = victories.filter { victory in
            switch filterMode {
            case .all:
                return true
            case .year:
                return calendar.isDate(victory.timestamp, equalTo: now, toGranularity: .year)
            case .threeMonths:
                if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) {
                    return victory.timestamp >= threeMonthsAgo
                }
                return false
            }
        }
        
        selectedVictories = Set(filteredVictories.map { $0.id })
    }
    
    private func toggleSelection(for victory: AlmostMoment) {
        if selectedVictories.contains(victory.id) {
            selectedVictories.remove(victory.id)
        } else {
            selectedVictories.insert(victory.id)
        }
    }
    
    private func generateVideo() {
        let victoriesToProcess = victories.filter { selectedVictories.contains($0.id) }
        guard !victoriesToProcess.isEmpty else { return }
        
        isGenerating = true
        errorMessage = nil
        progress = 0.0
        
        Task {
            do {
                let url = try await VideoGeneratorService.shared.generateNewYearVideo(from: victoriesToProcess) { currentProgress in
                    Task { @MainActor in
                        self.progress = currentProgress
                    }
                }
                await MainActor.run {
                    generatedVideoURL = url
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
}

