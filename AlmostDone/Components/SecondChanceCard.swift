//
//  SecondChanceCard.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct SecondChanceCard: View {
    let moment: AlmostMoment
    let daysRemaining: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Second Chance Active")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let days = daysRemaining {
                Text("\(days) days remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let text = moment.text, !text.isEmpty {
                Text(text)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Closeness: \(moment.closenessPercentage)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(moment.categoryEnum.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
        )
    }
}

