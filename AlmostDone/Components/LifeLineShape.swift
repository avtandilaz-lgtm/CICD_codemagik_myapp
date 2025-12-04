//
//  LifeLineShape.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct LifeLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midY = height / 2
        
        path.move(to: CGPoint(x: 0, y: midY))
        
        // Create a wavy line
        let waveLength: CGFloat = 150
        let amplitude: CGFloat = 30
        
        var x: CGFloat = 0
        while x < width {
            path.addCurve(
                to: CGPoint(x: x + waveLength, y: midY),
                control1: CGPoint(x: x + waveLength / 2, y: midY - amplitude),
                control2: CGPoint(x: x + waveLength / 2, y: midY + amplitude)
            )
            x += waveLength
        }
        
        return path
    }
}

struct LifeLineBackground: View {
    var body: some View {
        LifeLineShape()
            .stroke(
                Color.secondary.opacity(0.2),
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [10, 10]
                )
            )
    }
}

