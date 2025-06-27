# Melody Map
Discover songs from your favorite kids' movies — fast.
Melody Map is a simple, visual-first app that helps parents, grandparents, babysitters, and caregivers quickly find, play, and enjoy songs from animated and live-action movies.

Built with scalability in mind, Melody Map starts with a clean search-driven experience and aims to grow into a smart, automated music discovery tool for families.

## Features
🎵 **Smart Song Search** — instantly find any song with a single search bar

🎬 **Movie Timeline View** — see where each song appears in the movie with an intuitive timeline. **Navigation is now strictly within a single movie; users cannot swipe or curl to other movies from the timeline.**

📋 **Manually Curated Content** — all songs are added and tagged by hand to ensure quality

🎯 **Usage Tracking** — daily limits (3 views/day) with extension options via rewarded ads or subscription

🛡️ **Unified Quota Handling** — The Quota Exceeded Sheet now appears consistently when out of daily uses, both in search and timeline views, for a seamless experience.

💎 **Premium Subscription** — unlock unlimited song views with monthly or yearly plans

✨ **Pixie Burst Animation** — magical transition effects when moving from splash to main app

- **Timeline Navigation:** Arrow navigation between songs now consumes a daily use and will show the QuotaExceededSheet if out of quota.
- **Unified Quota Handling:** The QuotaExceededSheet is now used for all quota-exceeded actions, including arrow navigation, and no longer shows today's usage or a progress bar.
- **Profile Button Consistency:** The profile button is now visually aligned in both TimelineView and SearchView, matching the navigation bar style.
- **Timecode Formatting:** Song timecodes are always displayed as HH:MM:SS.
- **Release Year Display:** Release year is always shown without a comma.
- **Centralized Floating Action Buttons:** All floating action buttons (close, upgrade, favorite) are now managed in a single overlay layer, visually consistent, and fixed to the screen corners for a seamless and accessible experience.

## Floating Action Button (FAB) Overlay System
Melody Map uses a centralized Floating Action Button overlay for all key actions:
- **Close (X) Button:** Always fixed to the top-right corner when in TimelineView.
- **Upgrade (+) Button:** Always fixed to the bottom-left corner (if not subscribed).
- **Favorites (★) Button:** Always fixed to the bottom-right corner (if favorites exist).
- All FABs use a shared style for icon size, color, and drop shadow, ensuring visual and behavioral consistency.
- FABs are never affected by content resizing or scrolling, and always maintain a 44pt+ tap target for accessibility.

## Current Development Status

### ✅ **Completed**
- Core app architecture with SwiftUI
- Google Sheets integration via Apps Script
- Search functionality with fuzzy matching
- Timeline view with page transitions
- Usage tracking system with daily quotas (3 views/day)
- Quota exceeded sheet UI component
- Mock ad system for development testing
- PurchaseService with compile-time StoreKit guard
- PaywallView with subscription options
- Quota checking integration in Timeline and Search views
- **New Navigation Architecture** — AppState-driven navigation with SearchView as home screen
- **Pixie Burst Transition** — magical animation when transitioning from splash to main app
- **Splash Screen Gating** — waits for both minimum time (2.5s) and data readiness
- **Daily Uses Counter** — persistent tracking with proper initialization
- **Centralized Floating Action Button Overlay** — all FABs are now managed in a single overlay layer for consistency and accessibility

### 🛠️ **In Progress**
- UI polish and refinement
- User experience optimization
- Content management system

### 📋 **Planned**
- Google Ads integration (compile-time flag controlled)
- StoreKit subscription implementation (compile-time flag controlled)
- Advanced search features
- Content expansion

## Technical Notes

### Usage Quota System
The app implements a daily usage quota system:
- **Free tier:** 3 song views per day (updated from 10)
- **Ad rewards:** +2 views per watched ad
- **Premium subscription:** Unlimited views
- **Reset:** Quota resets at midnight local time
- **Persistence:** Uses UserDefaults with proper initialization

### Navigation Architecture (Updated)
The app now uses a centralized navigation system:
- **AppState:** Manages splash/data readiness and navigation state
- **SearchView:** Primary home screen with search functionality
- **TimelineView:** Accessed via search results with smooth transitions
- **Overlay System:** Profile and paywall appear as overlays with closure-based dismissal
- **Pixie Burst:** Magical transition animation when moving from splash to main app
- **Centralized FAB Overlay:** All floating action buttons are managed in a single overlay layer, ensuring they remain fixed and visually consistent

### Google Ads Integration
Google Ads integration is temporarily disabled during development to focus on core functionality. The system uses a mock implementation that simulates successful ad views for testing purposes. This allows development to continue without SDK compatibility issues.

**To re-enable Google Ads later:**
1. Go to Project Settings ▸ Build Settings ▸ Other Swift Flags
2. Add `-D ADS_ENABLED`
3. Update to a compatible SDK version (v9.x series recommended for iOS 15.2)
4. Uncomment the Google Mobile Ads implementation
5. Re-add the framework to the project
6. Test with actual ad units

### StoreKit Integration
StoreKit integration is temporarily disabled during development. The system uses a mock implementation that shows "Purchases disabled" alerts for testing purposes.

**To re-enable StoreKit later:**
1. Go to Project Settings ▸ Build Settings ▸ Other Swift Flags
2. Add `-D SUBS_ENABLED`
3. Implement StoreKit 2 logic in PurchaseService
4. Test with sandbox environment

### Build Requirements
- iOS 15.2+
- Xcode 13+
- Swift 5.0+

## Target Audience
**Primary:** Parents with children ages 12 months to 7 years

**Secondary:** Grandparents, babysitters, and other caregivers

## Platforms
- **iOS first** (currently in development)
- Android planned

## Tech Stack
- **Frontend:** Swift + SwiftUI for a native iOS experience
- **CMS (initial):** Google Sheets
- **CMS (future scaling):** Full database + admin UI once adoption scales
- **AI Support:** OpenAI Codex assisting with coding tasks

## Design Principles
- One giant search bar for ease of use
- Clean, visual-first timeline (inspired by polished streaming apps)
- Fast, joyful interactions for busy caregivers
- Minimalist UX — designed for quick lookups, not deep browsing
- Magical transitions with pixie burst animations
- **Centralized FAB Overlay:** All floating action buttons are managed in a single overlay for consistency and accessibility

## Development Goals
1. Build MVP using Google Sheets as CMS with a native SwiftUI app
2. Refine UX with visual timeline and instant search
3. Collect usage feedback and iterate
4. Prepare for scale: migrate to full database + automated ingest pipeline when appropriate

## Project Status
✅ **New Navigation Architecture** — AppState-driven navigation with SearchView as home screen
✅ **Pixie Burst Animation** — magical transition when moving from splash to main app
✅ **Splash Screen Gating** — waits for both minimum time (2.5s) and data readiness
✅ **Daily Uses Counter** — persistent tracking with proper initialization and UserDefaults
✅ **UsageTrackerService** — properly initializes daily quota and tracks usage
✅ **Search → Timeline Navigation** — smooth transitions with proper movie indexing
✅ **Overlay System** — Profile and paywall use closure-based dismissal
✅ **iOS 15 compatibility** (NavigationView); ready for NavigationStack on iOS 16+
✅ **Centralized FAB Overlay** — all floating action buttons are now managed in a single overlay layer for consistency and accessibility
🛠️ UI polish and refinement in progress

## Project Structure

```
MelodyMap/
├── MelodyMapApp.swift          # App entry point, navigation, splash gating, pixie burst
├── Assets.xcassets/            # App icons and images
├── Info.plist                  # App configuration
├── Resources/                  # Static resources
├── Models/                     # Data models
│   ├── Song.swift
│   ├── Movie.swift
│   ├── UserProfile.swift
│   └── IndexedSong.swift
├── Networking/                 # API and data services
│   └── APIService.swift        # Loads/caches movies and songs
├── Views/                      # SwiftUI views
│   ├── SplashView.swift        # Disney-style splash with pixie trail animation
│   ├── SearchView.swift        # Home screen, search UI
│   ├── ProfileView.swift       # Profile, with onClose closure
│   ├── Components/
│   │   ├── FloatingActionButton.swift # Shared FAB component for all floating buttons
│   │   └── QuotaExceededSheet.swift
│   ├── UpgradeButton.swift     # (Legacy) Upgrade/paywall button (now replaced by FAB)
│   ├── DailyUsesCounterButton.swift # Profile/daily uses button
│   ├── Paywall/PaywallView.swift    # Paywall, with onClose closure
│   ├── TimelineView.swift      # Timeline navigation
│   ├── SongDetailView.swift
│   ├── MoviePageView.swift     # Individual movie pages with timeline
│   ├── PageCurlView.swift      # UIPageViewController wrapper
│   ├── UsageMeterView.swift
│   ├── StarButton.swift        # Favorite button (now uses FAB style)
│   └── FavoritesView.swift     # Favorites modal
├── ViewModels/                 # View models
│   ├── TimelineViewModel.swift
│   ├── SearchViewModel.swift   # Search, exposes loadForAppState
│   └── UserProfileViewModel.swift
├── Services/                   # Business logic services
│   ├── AdService.swift         # (Compile-time flag controlled)
│   ├── PurchaseService.swift   # (Compile-time flag controlled)
│   ├── UsageTrackerService.swift # Usage quota, injected at root
│   ├── DataSyncService.swift
│   └── InAppPurchaseService.swift
├── Extensions/                 # Swift extensions
│   └── Helpers.swift
├── GMASPM/                     # Google Mobile Ads SDK (disabled)
└── Tests/                      # Unit and UI tests
```

## Documentation
- **Functional Specification:** [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md)
- **Architecture Details:** [DESIGN_DOC.md](DESIGN_DOC.md)

## License
TBD — likely MIT or similar (to be finalized)

## Credits
- **Concept + direction:** Nathan Fisher
- **AI agent support:** OpenAI Codex / GPT-4o
- **UX inspiration:** top-tier kids apps, music discovery tools, and polished streaming platforms

## Key Changes (Latest)
- **Navigation Architecture:** AppState-driven navigation with SearchView as home screen
- **Pixie Burst Animation:** Magical transition when moving from splash to main app
- **Splash Screen Gating:** Waits for both minimum time (2.5s) and data readiness
- **Centralized FAB Overlay:** All floating action buttons are now managed in a single overlay layer for consistency and accessibility
