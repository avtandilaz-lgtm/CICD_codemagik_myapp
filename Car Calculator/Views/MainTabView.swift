import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject private var errorHandler: ErrorHandler
    @Query private var settings: [UserSettingsModel]
    @State private var selectedTab = 0
    
    private var userSettings: UserSettingsModel {
        settings.first ?? UserSettingsModel()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            CalculatorTabView()
                .tabItem {
                    Image(systemName: "x.squareroot")
                    Text("Calculator")
                }
                .tag(1)
            
            HistoryTabView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Statistics")
                }
                .tag(3)
            
            SettingsTabView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .preferredColorScheme(userSettings.theme == "system" ? nil : (userSettings.theme == "dark" ? .dark : .light))
        .errorAlert(errorHandler: errorHandler)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SeasonModel.self, ServiceCategoryModel.self, ServiceModel.self, CalculationModel.self, SelectedServiceModel.self, UserSettingsModel.self, configurations: config)
    
    return MainTabView()
        .modelContainer(container)
}

