import SwiftUI
import SwiftData

struct TipsView: View {
    let season: SeasonModel
    @Environment(\.colorScheme) private var colorScheme
    
    private var tips: [String] {
        season.getTips()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text(season.emoji)
                                .font(.system(size: 60))
                            
                            Text("Tips for \(season.name.lowercased()) season")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Tips list
                        VStack(spacing: 16) {
                            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                                TipCard(
                                    tip: tip,
                                    index: index + 1
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Tips")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TipCard: View {
    let tip: String
    let index: Int
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Number
            Text("\(index)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color.blue)
                )
            
            // Tip text
            Text(tip)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let winter = SeasonModel(id: "winter", name: "Winter", emoji: "❄️", order: 0)
    return TipsView(season: winter)
}

