import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    let pages = [
        OnboardingPage(
            title: "Welcome!",
            description: "Find out how much it costs to maintain your car in different seasons",
            icon: "car.fill",
            color: [Color.blue, Color.purple]
        ),
        OnboardingPage(
            title: "Smart Calculator",
            description: "Calculate maintenance costs based on your region and season",
            icon: "calculator.fill",
            color: [Color.orange, Color.pink]
        ),
        OnboardingPage(
            title: "Personal Tips",
            description: "Get recommendations for car care in each season",
            icon: "lightbulb.fill",
            color: [Color.green, Color.blue]
        ),
        OnboardingPage(
            title: "Calculation History",
            description: "Save all your calculations and track expenses",
            icon: "chart.bar.fill",
            color: [Color.purple, Color.indigo]
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: pages[currentPage].color,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                if currentPage == pages.count - 1 {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isPresented = false
                            dismiss()
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white.opacity(0.3))
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(.ultraThinMaterial)
                                    )
                            )
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(opacity)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

