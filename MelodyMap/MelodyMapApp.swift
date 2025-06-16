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
    @StateObject private var purchaseService = PurchaseService()
    @StateObject private var usageService    = UsageTrackerService()
    @StateObject private var adService       = AdService()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(purchaseService)
                .environmentObject(usageService)
                .environmentObject(adService)
        }
    }
}
