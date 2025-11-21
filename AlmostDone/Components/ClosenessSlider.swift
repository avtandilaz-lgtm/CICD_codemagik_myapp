//
//  ClosenessSlider.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct ClosenessSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How close were you?")
                .font(.headline)
            
            HStack {
                Text("\(Int(value))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorForPercentage(value))
                    .frame(width: 70) // Increased width to prevent wrapping
                    .fixedSize(horizontal: true, vertical: false) // Force single line
                    .shadow(color: value >= 99.9 ? .yellow.opacity(0.6) : .clear, radius: 5)
                
                Slider(value: $value, in: range, step: 1)
                    .tint(colorForPercentage(value))
            }
            
            HStack {
                Text("1%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("100%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func colorForPercentage(_ percentage: Double) -> Color {
        if percentage >= 99.9 {
            return .yellow // Gold for 100%
        }
        
        // Interpolate between Blue (0%) and Red (almost 100%)
        // 0% -> Blue
        // 50% -> Purple/Mix
        // 99% -> Red
        return Color(
            red: percentage / 100.0,
            green: 0,
            blue: 1.0 - (percentage / 100.0)
        )
    }
}

