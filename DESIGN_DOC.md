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
- **AdService** – preloads and presents rewarded ads. *(Currently disabled for development)*
- **PurchaseService** – handles StoreKit 2 flows and publishes `isSubscriber`.

### Views
- **TimelineView** – a `UIPageViewController` showing movie pages with snap points for songs.
- **SearchView** – global search with fuzzy/phonetic matching.
- **SongDetailView** – collapsible panel with streaming and purchase links.
- **ProfileView** – shows usage stats and subscription status.

## Data Flow
1. `APIService` downloads song and movie JSON from Apps Script, authenticated by a hidden token.
2. Data is written to `Library/Caches` for offline access.
3. ViewModels observe the cached data and update SwiftUI views.

## Usage Limits and Ads
Daily free usage is limited and can be extended by watching rewarded ads. `UsageTrackerService` coordinates quota with `AdService`. Subscribers bypass ads and limits.

**Note:** Google Ads integration is temporarily disabled during development to focus on core functionality. The ad system uses a mock implementation that simulates successful ad views for testing purposes.

## Technical Implementation Status

### ✅ Completed
- Basic app architecture with SwiftUI
- Service layer implementation
- Google Sheets integration via Apps Script
- Search functionality with fuzzy matching
- Timeline view with page transitions
- Usage tracking system
- Mock ad system for development

### 🚧 In Progress
- Core UI polish and refinement
- User experience optimization
- Content management system

### 📋 Planned
- Google Ads integration (temporarily disabled)
- In-app purchase system
- Advanced search features
- Content expansion

## Accessibility and Motion
All interactions use page-curl by default. When iOS Reduce Motion is enabled, transitions fall back to cross-fades. Tap targets are 44 pt or larger and timeline dots include VoiceOver labels.

## Development Notes

### Google Ads Integration
The Google Ads SDK integration has been temporarily disabled due to compatibility issues with iOS 15.2 and the current Xcode version. The system uses a mock implementation that:
- Simulates successful ad views for development
- Maintains the same API interface for easy re-enablement
- Logs ad-related actions instead of presenting actual ads

To re-enable Google Ads:
1. Update to a compatible SDK version (v9.x series recommended for iOS 15.2)
2. Uncomment the Google Mobile Ads imports and implementation
3. Re-add the framework to the project
4. Test with actual ad units

### Build Configuration
- iOS Deployment Target: 15.2
- SwiftUI-based architecture
- StoreKit framework included for future in-app purchases
- Clean build system without Google Ads dependencies

## Future Work
Remote-config keys will allow tuning quota and pricing without app updates. Additional features such as mini-audio previews and non-song markers are planned. Google Ads integration will be re-enabled once core functionality is polished and a compatible SDK version is identified.

