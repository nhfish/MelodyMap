//
//  MelodyMapApp.swift
//  MelodyMap
//
//  Created by Nathan Fisher on 6/13/25.
//

import SwiftUI

@main
struct MelodyMapApp: App {
    // Single shared instances
    @StateObject private var purchaseService = InAppPurchaseService.shared
    @StateObject private var usageService    = UsageTrackerService.shared
    @StateObject private var adService       = AdService.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(purchaseService)
                .environmentObject(usageService)
                .environmentObject(adService)
        }
    }
}
