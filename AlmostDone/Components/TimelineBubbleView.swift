//
//  TimelineBubbleView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct TimelineBubbleView: View {
    let moment: AlmostMoment
    let maxSize: CGFloat = 200
    let minSize: CGFloat = 60
    
    @State private var isFloating = false
    @State private var floatOffset: CGFloat = 0
    @State private var isVisible = false // For entrance animation
    
    private var bubbleColor: Color {
        if moment.isVictory { return .yellow }
        switch moment.categoryEnum {
        case .love: return .pink
        case .career: return .blue
        case .sport: return .green
        case .travel: return .cyan
        case .creativity: return .purple
        case .extreme: return .red
        case .health: return .mint
        case .other: return .gray
        }
    }
    
    var body: some View {
        let size = calculateSize()
        
        VStack(spacing: 8) {
            ZStack {
                // Glow Layer (New)
                if moment.isVictory {
                    Circle()
                        .fill(Color.yellow)
                        .blur(radius: 20)
                        .opacity(0.6)
                        .frame(width: size * 1.4, height: size * 1.4) // Increased from 1.2 to 1.4
                } else {
                    Circle()
                        .fill(bubbleColor)
                        .blur(radius: 15)
                        .opacity(Double(moment.closenessPercentage) / 100.0 * 0.5) // Brightness depends on %
                        .frame(width: size * 1.1, height: size * 1.1)
                }
                
                // Soap Bubble Layer
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                bubbleColor.opacity(0.1),
                                bubbleColor.opacity(0.4)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size / 2
                        )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .overlay(
                        // Inner shadow simulation
                        Circle()
                            .stroke(bubbleColor.opacity(0.3), lineWidth: 4)
                            .blur(radius: 4)
                            .mask(Circle())
                    )
                    .overlay(
                        // Specular highlight (Reflection)
                        GeometryReader { geometry in
                            Path { path in
                                let w = geometry.size.width
                                let h = geometry.size.height
                                path.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.15, width: w * 0.35, height: h * 0.20))
                            }
                            .fill(Color.white.opacity(0.6))
                            .blur(radius: 10)
                            .rotationEffect(.degrees(-45))
                        }
                    )
                    .shadow(color: bubbleColor.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Category Icon
                if moment.isVictory {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.white) // Changed from .yellow to .white for better contrast
                        .shadow(color: .orange.opacity(0.8), radius: 8, x: 0, y: 0) // Stronger shadow
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                } else {
                    Image(systemName: moment.categoryEnum.iconName)
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .frame(width: size * 1.4, height: size * 1.4) // Increased frame to accommodate glow
            .scaleEffect(isVisible ? 1 : 0.1) // Entrance scale
            .opacity(isVisible ? 1 : 0) // Entrance opacity
            .offset(y: floatOffset)
            .onAppear {
                // Entrance Animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(Double.random(in: 0...0.3))) {
                    isVisible = true
                }
                
                // Floating Animation
                // Use a unique animation ID or check if already animating to prevent cancellation on re-render
                if !isFloating {
                    isFloating = true
                    let duration = Double.random(in: 2.0...4.0)
                    let delay = Double.random(in: 0...1.0)
                    
                    withAnimation(
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                    ) {
                        floatOffset = -10
                    }
                }
            }
            
            // Date Label
            Text(dateString)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .opacity(isVisible ? 1 : 0)
                .padding(.top, 20) // Increased spacing (10 -> 20)
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: moment.timestamp)
    }
    
    private func calculateSize() -> CGFloat {
        let percentage = CGFloat(moment.closenessPercentage)
        let normalized = percentage / 100.0
        // Quadratic easing for more dramatic size difference
        return minSize + (maxSize - minSize) * (normalized * normalized + 0.2) // Ensure slightly larger base for visibility
    }
}
