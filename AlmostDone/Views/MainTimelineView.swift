//
//  MainTimelineView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData

struct MainTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MainViewModel()
    @State private var showAddView = false
    @State private var showSettings = false
    @State private var selectedMoment: AlmostMoment?
    @State private var showDetail = false
    @State private var scrollPosition: Int? // Tracks visible item ID (using index or hash)
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Active Second Chance Card
                        if let secondChance = viewModel.activeSecondChance,
                           let daysRemaining = SecondChanceManager.shared.daysRemaining(for: secondChance) {
                            SecondChanceCard(moment: secondChance, daysRemaining: daysRemaining)
                                .padding(.horizontal)
                                .onTapGesture {
                                    selectedMoment = secondChance
                                    showDetail = true
                                }
                        }
                        
                        // Counter
                        HStack {
                            Text("\(viewModel.totalAlmostCount) almost")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("\(viewModel.totalVictoriesCount) victories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .padding(.bottom, 20) // Added extra bottom padding for spacing
                        
                        // Timeline
                        MomentsTimelineView(
                            moments: viewModel.moments,
                            onAddTap: { showAddView = true },
                            onMomentTap: { moment in
                                selectedMoment = moment
                                showDetail = true
                            }
                        )
                    }
                    .padding(.bottom, 100)
                }
                .scrollContentBackground(.hidden) // Hide default scroll background
            }
            .withAppBackground() // Apply custom background
            .navigationTitle("Almost Done")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddView) {
                AddAlmostView(context: modelContext)
                    .onDisappear {
                        viewModel.refresh()
                    }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(context: modelContext)
            }
            .sheet(item: $selectedMoment) { moment in
                AlmostDetailView(moment: moment, context: modelContext)
                    .onDisappear {
                        viewModel.refresh()
                    }
            }
            .onAppear {
                viewModel.setup(context: modelContext)
            }
        }
    }
}

// Timeline View Component
struct MomentsTimelineView: View {
    let moments: [AlmostMoment]
    let onAddTap: () -> Void
    let onMomentTap: (AlmostMoment) -> Void
    
    @State private var isAtEnd = true
    @State private var showScrollButton = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .center) {
                        // Life Line Background
                        LifeLineBackground()
                            .frame(height: 200)
                            .padding(.horizontal)
                        
                        HStack(alignment: .center, spacing: 60) { // Increased spacing by 50% (40 -> 60)
                            // Existing Moments
                            ForEach(moments) { moment in
                                TimelineBubbleView(moment: moment)
                                    .onTapGesture {
                                        onMomentTap(moment)
                                    }
                                    .frame(minWidth: 80)
                                    .id(moment.id) // For ScrollViewReader
                            }
                            
                            // Add New Moment Bubble (End of Timeline)
                            AddMomentBubbleView()
                                .onTapGesture {
                                    onAddTap()
                                }
                                .frame(minWidth: 80)
                                .id("addButton") // Special ID
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: VisibilityPreferenceKey.self,
                                            value: geo.frame(in: .named("scroll")).minX
                                        )
                                    }
                                )
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 40)
                    }
                }
                .coordinateSpace(name: "scroll")
                .frame(height: 320)
                .onPreferenceChange(VisibilityPreferenceKey.self) { minX in
                    // If minX is significantly larger than screen width, the button is off-screen to the right
                    // If minX is smaller than screen width, the button is visible
                    
                    let screenWidth = UIScreen.main.bounds.width
                    // Check if the "Add Button" is visible within the scroll view's viewport
                    // We use a threshold (e.g., screenWidth) to determine visibility
                    
                    // If minX > screenWidth, it means it's offscreen to the right (not reached yet)
                    // If minX < 0, it's offscreen to the left (scrolled past) - unlikely here as it is at the end
                    // We want to show the arrow when the user scrolls AWAY from the end (to the left)
                    // So the "Add Button" moves to the right, offscreen.
                    
                    let isVisible = minX < screenWidth
                    withAnimation {
                        showScrollButton = !isVisible
                    }
                }
                .onAppear {
                    // Auto-scroll to end on appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            proxy.scrollTo("addButton", anchor: .center)
                        }
                    }
                }
                
                // Scroll to End Button
                if showScrollButton {
                    Button(action: {
                        withAnimation {
                            proxy.scrollTo("addButton", anchor: .center)
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }
}

struct AddMomentBubbleView: View {
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.1),
                                Color.blue.opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: "plus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 100)
            .offset(y: floatOffset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
                ) {
                    floatOffset = -10
                }
            }
            
            Text("Add New")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct VisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
