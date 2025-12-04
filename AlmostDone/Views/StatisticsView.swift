//
//  StatisticsView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData
import Charts
import MapKit

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var showAchievements = false
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) { // Increased spacing
                    
                    // Top Categories (Podium) - Moved to TOP
                    if !viewModel.topCategories.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            HStack(alignment: .bottom, spacing: 16) {
                                // #2 Silver (Left)
                                if viewModel.topCategories.count > 1 {
                                    PodiumItem(
                                        data: viewModel.topCategories[1],
                                        rank: 2,
                                        color: .gray
                                    )
                                }
                                
                                // #1 Gold (Center)
                                if let first = viewModel.topCategories.first {
                                    PodiumItem(
                                        data: first,
                                        rank: 1,
                                        color: .yellow
                                    )
                                }
                                
                                // #3 Bronze (Right)
                                if viewModel.topCategories.count > 2 {
                                    PodiumItem(
                                        data: viewModel.topCategories[2],
                                        rank: 3,
                                        color: .orange
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20) // Added top padding for visual balance
                    }
                    
                    // Evolution Chart
                    if !viewModel.averageClosenessByMonth.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Evolution Over Time")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top, 20) // Added top padding
                            
                            Chart {
                                ForEach(viewModel.averageClosenessByMonth, id: \.period) { data in
                                    LineMark(
                                        x: .value("Period", data.period),
                                        y: .value("Average", data.average)
                                    )
                                    .interpolationMethod(.catmullRom) // Smooth curve
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .symbol {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 8, height: 8)
                                    }
                                    
                                    AreaMark(
                                        x: .value("Period", data.period),
                                        y: .value("Average", data.average)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                }
                            }
                            .frame(height: 220)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .padding()
                        }
                        .background(Color(uiColor: .secondarySystemBackground).opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Obstacle Pie Chart
                    if !viewModel.obstacleDistribution.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What Stops You Most?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(viewModel.obstacleDistribution, id: \.obstacle) { data in
                                    SectorMark(
                                        angle: .value("Count", data.count),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(colorForObstacle(data.obstacle))
                                    .cornerRadius(4)
                                }
                            }
                            .frame(height: 220)
                            .padding()
                            
                            // Legend
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                ForEach(viewModel.obstacleDistribution, id: \.obstacle) { data in
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(colorForObstacle(data.obstacle))
                                            .frame(width: 8, height: 8)
                                        Text("\(data.obstacle.displayName) (\(data.count))")
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .background(Color(uiColor: .secondarySystemBackground).opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // World Heat Map
                    if !viewModel.locations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Where You Almost Did It")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    zoomToFit(locations: viewModel.locations)
                                }) {
                                    Image(systemName: "scope")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            Map(position: $mapCameraPosition) {
                                ForEach(Array(viewModel.locations.enumerated()), id: \.offset) { index, location in
                                    Marker("", coordinate: location)
                                        .tint(.red)
                                }
                            }
                            .frame(height: 300)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Top Painful Moments (Ranked List)
                    if !viewModel.topPainfulMoments.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Most Painful Moments")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(viewModel.topPainfulMoments.prefix(3).enumerated()), id: \.element.id) { index, moment in
                                    PainfulMomentRow(moment: moment, rank: index + 1)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .scrollContentBackground(.hidden)
            .withAppBackground()
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAchievements = true
                    }) {
                        Image(systemName: "trophy.circle.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .onAppear {
                viewModel.setup(context: modelContext)
                if !viewModel.locations.isEmpty {
                    zoomToFit(locations: viewModel.locations)
                }
            }
        }
    }
    
    private func zoomToFit(locations: [CLLocationCoordinate2D]) {
        guard !locations.isEmpty else { return }
        
        var minLat = locations[0].latitude
        var maxLat = locations[0].latitude
        var minLon = locations[0].longitude
        var maxLon = locations[0].longitude
        
        for location in locations {
            minLat = min(minLat, location.latitude)
            maxLat = max(maxLat, location.latitude)
            minLon = min(minLon, location.longitude)
            maxLon = max(maxLon, location.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5 + 0.1, // Add padding
            longitudeDelta: (maxLon - minLon) * 1.5 + 0.1
        )
        
        withAnimation {
            mapCameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
    
    private func colorForObstacle(_ obstacle: Obstacle) -> Color {
        switch obstacle {
        case .fear: return .red
        case .laziness: return .orange
        case .shame: return .purple
        case .otherPerson: return .blue
        case .money: return .green
        case .time: return .cyan
        case .chance: return .yellow
        case .health: return .mint
        case .lackOfKnowledge: return .indigo
        case .other: return .gray
        }
    }
}

// Subviews

struct PodiumItem: View {
    let data: (category: Category, average: Double)
    let rank: Int
    let color: Color
    
    var body: some View {
        VStack {
            CategoryIconView(category: data.category, size: 30)
                .padding(8)
                .background(Circle().fill(Color.white))
                .shadow(radius: 2)
                .offset(y: 15)
                .zIndex(1)
            
            VStack(spacing: 4) {
                Spacer()
                Text("\(Int(data.average))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: rank == 1 ? 140 : (rank == 2 ? 110 : 90))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
            )
            .overlay(
                Text("\(rank)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                    .offset(y: 10)
                , alignment: .top
            )
        }
    }
}

struct PainfulMomentRow: View {
    let moment: AlmostMoment
    let rank: Int
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Number
            Text("\(rank)")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [rankColor, rankColor.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: rankColor.opacity(0.3), radius: 2, x: 1, y: 1)
                .frame(width: 40)
            
            // Card
            HStack(spacing: 12) {
                // Icon
                Image(systemName: moment.obstacleEnum.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.2)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(moment.obstacleEnum.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let text = moment.text, !text.isEmpty {
                        Text(text)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(Color.white)
                                .frame(width: geo.size.width * (CGFloat(moment.closenessPercentage) / 100.0), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                
                Spacer()
                
                Text("\(moment.closenessPercentage)%")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.red.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .red.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}
