import SwiftUI

struct SeasonCardView: View {
    let season: SeasonModel
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(season.emoji)
                .font(.system(size: 40))
            
            Text(season.name)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            if isCurrent {
                Spacer()
                Text("Current")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue, in: Capsule())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let winter = SeasonModel(id: "winter", name: "Winter", emoji: "❄️", order: 0)
    let spring = SeasonModel(id: "spring", name: "Spring", emoji: "🌸", order: 1)
    
    return VStack {
        SeasonCardView(season: winter, isCurrent: true)
        SeasonCardView(season: spring, isCurrent: false)
    }
    .padding()
}
