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
- **AdService** – preloads and presents rewarded ads.
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

## Accessibility and Motion
All interactions use page-curl by default. When iOS Reduce Motion is enabled, transitions fall back to cross-fades. Tap targets are 44 pt or larger and timeline dots include VoiceOver labels.

## Future Work
Remote-config keys will allow tuning quota and pricing without app updates. Additional features such as mini-audio previews and non-song markers are planned.

