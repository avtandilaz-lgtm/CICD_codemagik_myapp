//
//  VictoryCardView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct VictoryCardView: View {
    let moment: AlmostMoment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                Text("VICTORY")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                Spacer()
                
                // Category Icon moved to top right
                CategoryIconView(category: moment.categoryEnum)
                    .scaleEffect(0.8)
                    .padding(4) // Reduced padding (8 -> 4)
                    .background(Circle().fill(Color.white.opacity(1.0))) // Fully opaque (0.2 -> 1.0)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
            }
            
            // Victory Feeling (чувства от победы)
            if let feeling = moment.victoryFeeling, !feeling.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    // Header removed as requested
                    Text("\"\(feeling)\"")
                        .font(.title3) // Increased size (was .subheadline)
                        .fontWeight(.medium)
                        .italic()
                        .foregroundColor(.white)
                }
            }
            
            // Description (описание трудностей)
            if let text = moment.text, !text.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Text(text)
                        .font(.subheadline) // Decreased size (was .body)
                        .foregroundColor(.white.opacity(0.9)) // Changed to white for better contrast on gradient
                    
                    Spacer()
                    
                    Text(moment.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.white) // Pure white
                }
            } else {
                // If no text, show date on the right
                HStack {
                    Spacer()
                    Text(moment.timestamp, style: .date)
                        .font(.caption)
                        .foregroundColor(.white) // Pure white
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.8)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

