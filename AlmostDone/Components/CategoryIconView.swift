//
//  CategoryIconView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct CategoryIconView: View {
    let category: Category
    let size: CGFloat
    
    init(category: Category, size: CGFloat = 24) {
        self.category = category
        self.size = size
    }
    
    var body: some View {
        Image(systemName: category.iconName)
            .font(.system(size: size))
            .foregroundColor(colorForCategory(category))
    }
    
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
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
}

