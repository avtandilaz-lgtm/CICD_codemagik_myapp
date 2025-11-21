//
//  ProgressBubbleView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct ProgressBubbleView: View {
    let percentage: Int
    let isVictory: Bool
    let categoryColor: Color
    
    // Animation states
    @State private var isAnimating = false
    @State private var floatOffset: CGFloat = 0
    
    var mainColor: Color {
        isVictory ? .yellow : categoryColor
    }
    
    var body: some View {
        ZStack {
            // 1. Glass Bubble Background
            Circle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
            
            // 2. Background Ring
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 25)
                .padding(12) // Inset slightly inside the glass bubble
            
            // 3. Active Progress Ring
            Circle()
                .trim(from: 0, to: isAnimating ? CGFloat(percentage) / 100.0 : 0)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            mainColor.opacity(0.6),
                            mainColor,
                            mainColor.opacity(0.8)
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + 360 * Double(percentage) / 100.0)
                    ),
                    style: StrokeStyle(lineWidth: 25, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(12)
                .shadow(color: mainColor.opacity(0.5), radius: 10, x: 0, y: 0) // Glow
            
            // 4. Specular Highlight (Reflection) - REMOVED as requested
            /*
            GeometryReader { geometry in
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height
                    // Top-left reflection
                    path.addEllipse(in: CGRect(x: w * 0.2, y: h * 0.15, width: w * 0.4, height: h * 0.25))
                }
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(-45))
                .blur(radius: 5)
            }
            */
            
            // 5. Text Content
            VStack(spacing: 0) {
                if isVictory {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .yellow], startPoint: .bottom, endPoint: .top)
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 5)
                        .padding(.bottom, 4)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(Double(percentage)))") // Animate this if needed, but simple text for now
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(value: Double(percentage)))
                    
                    Text("%")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .offset(y: -16)
                }
                
                Text(isVictory ? "COMPLETE" : "CLOSE")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(2)
                    .padding(.top, -4)
            }
        }
        .frame(width: 220, height: 220)
        // Entrance Animation
        .scaleEffect(isAnimating ? 1 : 0.8)
        .opacity(isAnimating ? 1 : 0)
        // Floating Animation
        .offset(y: floatOffset)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            // Gentle floating animation
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
                .delay(0.5)
            ) {
                floatOffset = -5
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        ProgressBubbleView(percentage: 85, isVictory: false, categoryColor: .blue)
    }
}

