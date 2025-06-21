# Melody Map · Design Document

This document summarizes the high-level architecture and design decisions for Melody Map. See [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md) for the full functional specification that governs features and data contracts.

## Overview
Melody Map is an iOS-first app built with Swift and SwiftUI. It helps parents and caregivers quickly locate Disney movie songs. The app focuses on a polished, storybook aesthetic with page-curl transitions, gentle sparkles, and magical pixie burst animations. Content is sourced from a Google Sheet and cached locally for offline use.

## Architecture (Updated)
- **AppState**: Manages splash/data readiness and navigation state. Splash screen is gated on both minimum time (2.5s) and data readiness (movies/songs loaded).
- **Navigation**: AppState-driven navigation with SearchView as home screen, TimelineView accessed via search results
- **SearchViewModel**: Exposes a static loadForAppState for splash gating.
- **UsageTrackerService**: Injected at the root of the app with proper initialization (3 views/day).
- **Views**: SearchView is the primary home screen, with overlays for upgrade/profile. Profile and paywall overlays use closure-based dismissal.
- **Pixie Burst**: Magical transition animation when moving from splash to main app.
- **Navigation**: Uses NavigationView for iOS 15 compatibility; ready to migrate to NavigationStack for iOS 16+.

### Services
- **APIService** – fetches JSON from the Apps Script middleware and caches it locally.
- **TimelineViewModel** – controls the page controller and holds movie/song arrays.
- **SearchViewModel** – builds an in-memory search index and returns grouped results.
- **SongDetailViewModel** – manages expansion state and favorites.
- **UsageTrackerService** – tracks daily song views (3/day) and resets the quota with proper UserDefaults persistence. It also tracks recently "unlocked" songs, allowing free re-watches for 15 minutes.
- **FavoritesService** – manages a persistent list of favorited song IDs using UserDefaults.
- **AdService** – preloads and presents rewarded ads. *(Uses compile-time flag ADS_ENABLED)*
- **PurchaseService** – handles StoreKit 2 flows and publishes `isSubscriber`. *(Uses compile-time flag SUBS_ENABLED)*
- **MusicKitService** – handles Apple Music integration for 30-second song previews, including authorization and catalog search.

### Views
- **SplashView** – Disney-style splash screen with pixie trail animation and minimum display time.
- **SearchView** – global search with fuzzy/phonetic matching, primary home screen.
- **TimelineView** – a `UIPageViewController` showing movie pages with snap points for songs, accessed via search results.
- **SongDetailView** – collapsible panel with streaming and purchase links.
- **FavoritesView** – a modal sheet that displays a list of all songs the user has favorited.
- **ProfileView** – shows usage stats and subscription status, overlay with closure-based dismissal.
- **QuotaExceededSheet** – modal sheet for when daily limits are reached.
- **PaywallView** – subscription upgrade interface with monthly/yearly options, overlay with closure-based dismissal.
- **PixieBurstTransitionView** – magical particle animation for splash-to-main transitions.
- **SongPreviewButton** – unobtrusive button next to timecodes for playing Apple Music previews.
- **AudioPreviewPlayer** – simple play/stop controls for 30-second song previews.

## Data Flow (Updated)
1. AppState calls SearchViewModel.loadForAppState to load movies and songs for splash gating.
2. Splash screen remains until both minimum time (2.5s) and data readiness are met.
3. Pixie burst animation triggers when transitioning from splash to main app.
4. UsageTrackerService is injected at the root for quota tracking (3 views/day).
5. SearchView serves as home screen with search functionality.
6. TimelineView is accessed via search results with smooth transitions.
7. Profile and paywall overlays use closure-based dismissal.
8. MusicKitService handles Apple Music preview requests on-demand.

## Usage Limits and Monetization
Daily free usage is limited to 3 song views per day (updated from 10). Users can extend their quota by:
- Watching rewarded ads (+2 views per ad)
- Upgrading to premium subscription (unlimited views)

A "song view" is consumed when a user navigates to a new song. Once a song is viewed, it enters a 15-minute "free re-watch" window where it can be viewed again without consuming additional uses.

**Quota System:**
- `UsageTrackerService` tracks daily consumption with proper UserDefaults persistence
- Quota resets at midnight local time
- Quota exceeded sheet appears when limit is reached
- Ad rewards and subscription status are managed by respective services
- Daily uses counter shows current usage with proper initialization

**Note:** Both Google Ads and StoreKit integration use compile-time flags that can be toggled in Project Settings ▸ Build Settings ▸ Other Swift Flags:
- `ADS_ENABLED` - Controls Google Mobile Ads integration
- `SUBS_ENABLED` - Controls StoreKit subscription functionality

When disabled, the systems use mock implementations for development and testing.

## MusicKit Integration
**Apple Music Previews:**
- 30-second song previews available for all users (no Apple Music subscription required)
- Permission requested only when user first taps a preview button
- Search by movie title + song title for optimal matching
- Graceful fallback if previews unavailable or permission denied
- Simple tap-to-play, tap-to-stop controls
- Automatic cleanup when leaving view

**Technical Implementation:**
- `MusicKitService` handles authorization and catalog search
- `AudioPreviewPlayer` manages playback with AVAudioPlayer
- Preview buttons appear unobtrusively next to timecodes
- Loading states with progress indicators
- Memory management with proper delegate patterns

## Technical Implementation Status

### ✅ Completed
- Basic app architecture with SwiftUI
- Service layer implementation
- Google Sheets integration via Apps Script
- Search functionality with fuzzy matching
- Timeline view with page transitions
- Usage tracking system with daily quotas (3 views/day)
- Quota exceeded sheet UI component
- Mock ad system for development
- PurchaseService with compile-time StoreKit guard
- PaywallView with subscription options
- Quota checking integration in Timeline and Search views
- **New Navigation Architecture** — AppState-driven navigation with SearchView as home screen
- **Pixie Burst Animation** — magical transition when moving from splash to main app
- **Splash Screen Gating** — waits for both minimum time (2.5s) and data readiness
- **Daily Uses Counter** — persistent tracking with proper initialization and UserDefaults
- **Search → Timeline Navigation** — smooth transitions with proper movie indexing
- **MusicKit Integration** — Apple Music previews with authorization and playback
- **Preview Button UI** — unobtrusive controls next to timecodes
- **Audio Preview Player** — simple play/stop functionality

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
All interactions use page-curl by default. When iOS Reduce Motion is enabled, transitions fall back to cross-fades. Tap targets are 44 pt or larger and timeline dots include VoiceOver labels. Pixie burst animations respect accessibility settings.

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

### MusicKit Integration
The MusicKit integration is always enabled and provides Apple Music preview functionality:

**Features:**
- 30-second song previews (no subscription required)
- On-demand permission requests
- Automatic catalog search and matching
- Graceful error handling

**Privacy:**
- `NSAppleMusicUsageDescription` in main app Info.plist
- Permission requested only when needed
- Clear user messaging about preview functionality

### Build Configuration
- iOS Deployment Target: 15.2
- SwiftUI-based architecture
- StoreKit framework included for future in-app purchases
- MusicKit framework for Apple Music previews
- Clean build system with optional Google Ads dependencies

## Future Work
Remote-config keys will allow tuning quota and pricing without app updates. Additional features such as mini-audio previews and non-song markers are planned. Both Google Ads and StoreKit integration can be easily enabled via their respective compile-time flags once core functionality is polished.

## Key Changes (Latest)
- **Navigation Architecture:** AppState-driven navigation with SearchView as home screen
- **Pixie Burst Animation:** Magical transition when moving from splash to main app
- **Splash Screen Gating:** Waits for both minimum time (2.5s) and data readiness
- **Daily Uses Counter:** Persistent tracking with proper initialization and UserDefaults
- **UsageTrackerService:** Properly initializes daily quota (3 views/day) and tracks usage
- **Search → Timeline Navigation:** Smooth transitions with proper movie indexing
- **Overlay System:** Profile and paywall use closure-based dismissal
- **iOS 15:** Uses NavigationView; ready to migrate to NavigationStack for iOS 16+
- **Timeline Navigation:** Users can now only navigate between songs within a single movie in the timeline view. Swiping or curling to other movies is disabled.
- **Favorites System:** Users can tap a star to favorite songs and access them via a dedicated button that appears in the lower-right corner when favorites exist.
- **Unified Quota Handling:** The QuotaExceededSheet is now presented consistently when out of daily uses, both in search and timeline views.
- **Improved UX:** Unified quota logic and modal handling for a seamless experience.
- **Arrow Navigation:** Arrow navigation in TimelineView now consumes a daily use and triggers the QuotaExceededSheet if out of quota.
- **QuotaExceededSheet:** Cleaner UI (no usage bar/text) and used for all quota-exceeded actions, including arrow navigation.
- **Profile Button Consistency:** Profile button is now visually aligned in both TimelineView and SearchView.
- **Timecode Formatting:** Song timecodes are always displayed as HH:MM:SS.
- **Release Year Display:** Release year is always shown without a comma.
- **MusicKit Integration:** Apple Music previews with 30-second previews, on-demand permission requests, and simple play/stop controls.
- **Preview Button UI:** Unobtrusive preview buttons next to timecodes in timeline view.
- **Audio Preview Player:** Simple audio playback component with proper memory management.

