//
//  AlmostDetailView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData
import AVKit

struct AlmostDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DetailViewModel
    @State private var showDeleteConfirmation = false
    
    let context: ModelContext
    
    init(moment: AlmostMoment, context: ModelContext) {
        self.context = context
        _viewModel = StateObject(wrappedValue: DetailViewModel(moment: moment))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isEditing {
                    editingView
                } else {
                    detailView
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Moment" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if viewModel.isEditing {
                        Button("Cancel") {
                            viewModel.cancelEditing()
                        }
                    } else {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isEditing {
                        Button("Save") {
                            viewModel.saveEditing()
                        }
                    } else {
                        Button("Edit") {
                            viewModel.startEditing()
                        }
                    }
                }
            }
            .alert("Delete Moment", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.delete()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this moment? This action cannot be undone.")
            }
            .onAppear {
                viewModel.setup(context: context)
            }
        }
    }
    
    private var detailView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Spacer for header
                Spacer().frame(height: 20)
                
                // Hero Bubble
                ProgressBubbleView(
                    percentage: viewModel.moment.closenessPercentage,
                    isVictory: viewModel.moment.isVictory,
                    categoryColor: viewModel.moment.categoryEnum.color
                )
                .padding(.top, 20)
                
                // Metadata Chips
                HStack(spacing: 12) {
                    // Category Chip
                    HStack(spacing: 6) {
                        CategoryIconView(category: viewModel.moment.categoryEnum)
                            .scaleEffect(0.8)
                        Text(viewModel.moment.categoryEnum.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(viewModel.moment.categoryEnum.color.opacity(0.15))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    // Obstacle Chip
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.moment.obstacleEnum.iconName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(viewModel.moment.obstacleEnum.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                
                // Media
                if let mediaURL = viewModel.moment.mediaURLValue {
                    VStack {
                        if isVideoFile(mediaURL) {
                            LoopingPlayerView(url: mediaURL)
                                .frame(height: 300)
                        } else if let image = MediaService.shared.loadImage(from: mediaURL) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 4)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .rotationEffect(.degrees(Double.random(in: -2...2))) // Slight tilt for photo feel
                }
                
                // Story Text
                if let text = viewModel.moment.text, !text.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.largeTitle)
                                .foregroundColor(.secondary.opacity(0.2))
                            Spacer()
                        }
                        .padding(.bottom, -20)
                        
                        Text(text)
                            .font(.system(.body, design: .serif)) // Serif for narrative feel
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                }
                
                // Victory Feeling (if victory)
                if viewModel.moment.isVictory {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Victory Feeling", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                        
                        if let feeling = viewModel.moment.victoryFeeling, !feeling.isEmpty {
                            Text(feeling)
                                .font(.system(.body, design: .serif))
                                .italic()
                                .foregroundColor(.primary)
                        } else if viewModel.moment.isVictory {
                             // Empty state for victory feeling
                             Text("No feeling recorded yet...")
                                 .font(.system(.body, design: .serif))
                                 .italic()
                                 .foregroundColor(.secondary.opacity(0.7))
                        } else {
                            TextField("How did it feel?", text: $viewModel.victoryFeeling, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                                .onSubmit {
                                    viewModel.saveVictoryFeeling()
                                }
                                .onChange(of: viewModel.victoryFeeling) { _ in
                                    viewModel.saveVictoryFeeling()
                                }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity) // Stretch to full width
                    .background(
                        ZStack {
                            Color.yellow.opacity(0.1)
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    if !viewModel.moment.isVictory {
                        // Complete Button
                        Button(action: {
                            withAnimation {
                                viewModel.convertToVictory()
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("I Did It!")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        if !viewModel.moment.secondChanceActive {
                            // Second Chance Button
                            Button(action: {
                                viewModel.activateSecondChance()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Give Second Chance")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        // Delete button
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground)) // Match Settings/Edit style
    }
    
    private var editingView: some View {
        Form {
            Section("Category") {
                Picker("Category", selection: $viewModel.editingCategory) {
                    ForEach(Category.allCases, id: \.self) { category in
                        HStack {
                            CategoryIconView(category: category)
                            Text(category.displayName)
                        }
                        .tag(category)
                    }
                }
            }
            
            Section("Closeness") {
                ClosenessSlider(
                    value: $viewModel.editingCloseness,
                    range: Double(Constants.minClosenessPercentage)...Double(Constants.maxClosenessPercentage)
                )
            }
            
            Section("Obstacle") {
                Picker("What stopped you?", selection: $viewModel.editingObstacle) {
                    ForEach(Obstacle.allCases, id: \.self) { obstacle in
                        HStack {
                            Image(systemName: obstacle.iconName)
                            Text(obstacle.displayName)
                        }
                        .tag(obstacle)
                    }
                }
            }
            
            Section("Story") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Tell your story...", text: $viewModel.editingText, axis: .vertical)
                        .lineLimit(3...6)
                    
                    HStack {
                        Spacer()
                        Text("\(viewModel.editingText.count)/\(Constants.maxTextLength)")
                            .font(.caption)
                            .foregroundColor(viewModel.editingText.count > Constants.maxTextLength ? .red : .secondary)
                    }
                }
            }
            
            if viewModel.moment.isVictory || Int(viewModel.editingCloseness) == 100 {
                Section("Victory Feeling") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("How did it feel?", text: $viewModel.editingVictoryFeeling, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
            }
            
            Section("Date & Time") {
                DatePicker("Date & Time", selection: $viewModel.editingDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    private func isVideoFile(_ url: URL) -> Bool {
        let videoExtensions = ["mov", "mp4", "m4v", "avi"]
        return videoExtensions.contains(url.pathExtension.lowercased())
    }
}

// Custom button style for press effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct LoopingPlayerView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> LoopingPlayerUIView {
        return LoopingPlayerUIView(url: url)
    }
    
    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {
        // No update needed for static URL
    }
}

class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private let playerQueue: AVQueuePlayer
    
    init(url: URL) {
        let item = AVPlayerItem(url: url)
        self.playerQueue = AVQueuePlayer(playerItem: item)
        self.playerLooper = AVPlayerLooper(player: playerQueue, templateItem: item)
        
        super.init(frame: .zero)
        
        playerLayer.player = playerQueue
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        playerQueue.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
