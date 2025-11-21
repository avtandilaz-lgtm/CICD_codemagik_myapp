//
//  AlmostDoneWidget.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), almostCount: 217, victoryCount: 14, activeSecondChance: "Example Moment", category: "Career", daysRemaining: 29, notificationText: "Don't give up!")
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchData()
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = fetchData()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))) // Update every hour
        completion(timeline)
    }
    
    @MainActor
    private func fetchData() -> SimpleEntry {
        // Read from SharedDataManager
        let widgetData = SharedDataManager.shared.loadWidgetData()
        
        // Note: almostCount and victoryCount would ideally also come from shared data or SwiftData
        // For now, we focus on the Second Chance data as requested
        
        return SimpleEntry(
            date: Date(),
            almostCount: 0, // Placeholder or need to sync this too
            victoryCount: 0, // Placeholder
            activeSecondChance: widgetData?.activeSecondChanceTitle,
            category: widgetData?.activeSecondChanceCategory,
            daysRemaining: widgetData?.daysRemaining,
            notificationText: widgetData?.notificationText
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let almostCount: Int
    let victoryCount: Int
    let activeSecondChance: String?
    let category: String?
    let daysRemaining: Int?
    let notificationText: String?
}

struct AlmostDoneWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let days = entry.daysRemaining {
                // Active Second Chance Mode
                Text("\(days)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.orange)
                Text("days left")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let category = entry.category {
                    Text(category)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            } else {
                // Default Stats Mode
                Text("Almost")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(entry.almostCount)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Victories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(entry.victoryCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            // Left side: Days Counter
            VStack(alignment: .leading) {
                if let days = entry.daysRemaining {
                    Text("\(days)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange)
                    Text("days left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("No Active")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Second Chance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80)
            
            Divider()
            
            // Right side: Details
            VStack(alignment: .leading, spacing: 4) {
                if let category = entry.category {
                    Text(category.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                if let notificationText = entry.notificationText {
                    Text(notificationText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                } else {
                    Text("Start a second chance to turn regret into victory.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Almost Done")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            
            if let days = entry.daysRemaining {
                VStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.orange.opacity(0.2), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: CGFloat(days) / 30.0)
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(days)")
                                .font(.system(size: 40, weight: .bold))
                            Text("days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(height: 120)
                    
                    if let category = entry.category {
                        Text(category)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if let text = entry.notificationText {
                        Text(text)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.05))
                .cornerRadius(16)
            } else {
                Text("No active second chance.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct AlmostDoneWidget: Widget {
    let kind: String = "AlmostDoneWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AlmostDoneWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AlmostDoneWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Second Chance")
        .description("Track your active second chance progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
