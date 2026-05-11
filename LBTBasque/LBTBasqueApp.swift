import AnalyticsKit
import SwiftUI
import UIKit

@main
struct LBTBasqueApp: App {
    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.925, alpha: 1)
        tabAppearance.shadowColor = UIColor.black.withAlphaComponent(0.08)
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.0, green: 0.43, blue: 0.18, alpha: 1)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 0.0, green: 0.43, blue: 0.18, alpha: 1)]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.08, green: 0.11, blue: 0.09, alpha: 1)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(red: 0.08, green: 0.11, blue: 0.09, alpha: 1)]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }

    var body: some Scene {
        WindowGroup {
            AnalyticsEntry(
                config: .lbtBasque,
                languageCode: Locale.current.language.languageCode?.identifier ?? "en",
                requestReviewBeforeCheck: false
            ) {
                LBTBasqueContentView()
            }
        }
    }
}

private extension AnalyticsLaunchConfig {
    private static let lbtBasqueBundleID = "com.lineb.pelotefrance"
    private static let lbtBasqueServerDomain = "onehabit.today"
    private static let lbtBasqueAnalyticsToken = "3dd0e1fee68441f8e02d19a943ceddd5cc03c786ef6d1d1a6913792086297d3c"

    static let lbtBasque = AnalyticsLaunchConfig(
        serverDomain: lbtBasqueServerDomain,
        analyticsToken: lbtBasqueAnalyticsToken,
        bundleID: Bundle.main.bundleIdentifier ?? lbtBasqueBundleID,
        initialCheckDelay: 0.45,
        requestTimeout: 7,
        requestStyle: .appIDOnly
    )
}
