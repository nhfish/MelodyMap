# Melody Map · Design Document

This document summarizes the high-level architecture and design decisions for Melody Map. See [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md) for the full functional specification that governs features and data contracts.

## Overview
Melody Map is an iOS-first app built with Swift and SwiftUI. It helps parents and caregivers quickly locate Disney movie songs. The app focuses on a polished, storybook aesthetic with page-curl transitions and gentle sparkles. Content is sourced from a Google Sheet and cached locally for offline use.

## Architecture
The codebase uses a lightweight service and ViewModel structure. Core services are injected using SwiftUI's `.environmentObject`.

### Services
- **APIService** – fetches JSON from the Apps Script middleware and caches it locally.
- **TimelineViewModel** – controls the page controller and holds movie/song arrays.
- **SearchViewModel** – builds an in-memory search index and returns grouped results.
- **SongDetailViewModel** – manages expansion state and favorites.
- **UsageTrackerService** – tracks daily song views and resets the quota.
- **AdService** – preloads and presents rewarded ads. *(Uses compile-time flag ADS_ENABLED)*
- **PurchaseService** – handles StoreKit 2 flows and publishes `isSubscriber`. *(Uses compile-time flag SUBS_ENABLED)*

### Views
- **TimelineView** – a `UIPageViewController` showing movie pages with snap points for songs.
- **SearchView** – global search with fuzzy/phonetic matching.
- **SongDetailView** – collapsible panel with streaming and purchase links.
- **ProfileView** – shows usage stats and subscription status.
- **QuotaExceededSheet** – modal sheet for when daily limits are reached.
- **PaywallView** – subscription upgrade interface with monthly/yearly options.

## Data Flow
1. `APIService` downloads song and movie JSON from Apps Script, authenticated by a hidden token.
2. Data is written to `Library/Caches` for offline access.
3. ViewModels observe the cached data and update SwiftUI views.

## Usage Limits and Monetization
Daily free usage is limited to 10 song views per day. Users can extend their quota by:
- Watching rewarded ads (+2 views per ad)
- Upgrading to premium subscription (unlimited views)

**Quota System:**
- `UsageTrackerService` tracks daily consumption
- Quota resets at midnight local time
- Quota exceeded sheet appears when limit is reached
- Ad rewards and subscription status are managed by respective services

**Note:** Both Google Ads and StoreKit integration use compile-time flags that can be toggled in Project Settings ▸ Build Settings ▸ Other Swift Flags:
- `ADS_ENABLED` - Controls Google Mobile Ads integration
- `SUBS_ENABLED` - Controls StoreKit subscription functionality

When disabled, the systems use mock implementations for development and testing.

## Technical Implementation Status

### ✅ Completed
- Basic app architecture with SwiftUI
- Service layer implementation
- Google Sheets integration via Apps Script
- Search functionality with fuzzy matching
- Timeline view with page transitions
- Usage tracking system with daily quotas
- Quota exceeded sheet UI component
- Mock ad system for development
- PurchaseService with compile-time StoreKit guard
- PaywallView with subscription options
- Quota checking integration in Timeline and Search views

### 🚧 In Progress
- Core UI polish and refinement
- User experience optimization
- Content management system

### 📋 Planned
- Google Ads integration (compile-time flag controlled)
- StoreKit subscription implementation (compile-time flag controlled)
- Advanced search features
- Content expansion

## Accessibility and Motion
All interactions use page-curl by default. When iOS Reduce Motion is enabled, transitions fall back to cross-fades. Tap targets are 44 pt or larger and timeline dots include VoiceOver labels.

## Development Notes

### Google Ads Integration
The Google Ads SDK integration uses a compile-time flag `ADS_ENABLED` for easy toggling:

**To enable Google Ads:**
1. Go to Project Settings ▸ Build Settings ▸ Other Swift Flags
2. Add `-D ADS_ENABLED`
3. Ensure Google Mobile Ads framework is added to the project
4. Test with actual ad units

**To disable Google Ads (current state):**
1. Remove `-D ADS_ENABLED` from Other Swift Flags
2. The system will use mock implementation
3. No Google Ads framework required

### StoreKit Integration
The StoreKit integration uses a compile-time flag `SUBS_ENABLED` for easy toggling:

**To enable StoreKit subscriptions:**
1. Go to Project Settings ▸ Build Settings ▸ Other Swift Flags
2. Add `-D SUBS_ENABLED`
3. Implement StoreKit 2 logic in PurchaseService
4. Test with sandbox environment

**To disable StoreKit (current state):**
1. Remove `-D SUBS_ENABLED` from Other Swift Flags
2. The system will use mock implementation
3. PaywallView shows "Purchases disabled" alert

### Build Configuration
- iOS Deployment Target: 15.2
- SwiftUI-based architecture
- StoreKit framework included for future in-app purchases
- Clean build system with optional Google Ads dependencies

## Future Work
Remote-config keys will allow tuning quota and pricing without app updates. Additional features such as mini-audio previews and non-song markers are planned. Both Google Ads and StoreKit integration can be easily enabled via their respective compile-time flags once core functionality is polished.

