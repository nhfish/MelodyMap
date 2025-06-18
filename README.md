# Melody Map
Discover songs from your favorite kids' movies — fast.
Melody Map is a simple, visual-first app that helps parents, grandparents, babysitters, and caregivers quickly find, play, and enjoy songs from animated and live-action movies.

Built with scalability in mind, Melody Map starts with a clean search-driven experience and aims to grow into a smart, automated music discovery tool for families.

## Features
🎵 **Smart Song Search** — instantly find any song with a single search bar

🎬 **Movie Timeline View** — see where each song appears in the movie with an intuitive timeline

📋 **Manually Curated Content** — all songs are added and tagged by hand to ensure quality

🎯 **Usage Tracking** — daily limits (10 views/day) with extension options via ads or premium subscription

💎 **Premium Subscription** — unlock unlimited song views with monthly or yearly plans

## Current Development Status

### ✅ **Completed**
- Core app architecture with SwiftUI
- Google Sheets integration via Apps Script
- Search functionality with fuzzy matching
- Timeline view with page transitions
- Usage tracking system with daily quotas
- Quota exceeded sheet UI component
- Mock ad system for development testing
- PurchaseService with compile-time StoreKit guard
- PaywallView with subscription options
- Quota checking integration in Timeline and Search views

### 🚧 **In Progress**
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
- **Free tier:** 10 song views per day
- **Ad rewards:** +2 views per watched ad
- **Premium subscription:** Unlimited views
- **Reset:** Quota resets at midnight local time

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

## Development Goals
1. Build MVP using Google Sheets as CMS with a native SwiftUI app
2. Refine UX with visual timeline and instant search
3. Collect usage feedback and iterate
4. Prepare for scale: migrate to full database + automated ingest pipeline when appropriate

## Project Status
✅ Splash screen now stays up until both minimum time and data load are complete
✅ AppState coordinates splash/data readiness
✅ MainTabView is deprecated; navigation is now in MelodyMapApp.swift
✅ SearchViewModel exposes a static loadForAppState for splash gating
✅ UsageTrackerService is injected at the root
✅ Only SearchView is the home screen, with overlays for upgrade/profile
✅ Profile and paywall overlays use new closure-based dismissal
✅ iOS 15 compatibility (NavigationView); ready for NavigationStack on iOS 16+
🚧 UI polish and refinement in progress

## Project Structure

```
MelodyMap/
├── MelodyMapApp.swift          # App entry point, navigation, splash gating
├── Assets.xcassets/            # App icons and images
├── Info.plist                  # App configuration
├── Resources/                  # Static resources
├── Models/                     # Data models
│   ├── Song.swift
│   ├── Movie.swift
│   ├── UserProfile.swift
│   └── IndexedSong.swift
├── Networking/                 # API and data services
│   ├── APIService.swift        # Loads/caches movies and songs
│   └── GoogleSheetsService.swift
├── Views/                      # SwiftUI views
│   ├── SplashView.swift        # Disney-style splash screen
│   ├── SearchView.swift        # Home screen, search UI
│   ├── ProfileView.swift       # Profile, with onClose closure
│   ├── UpgradeButton.swift     # Upgrade/paywall button
│   ├── DailyUsesCounterButton.swift # Profile/daily uses button
│   ├── Paywall/PaywallView.swift    # Paywall, with onClose closure
│   ├── TimelineView.swift
│   ├── SongDetailView.swift
│   ├── MoviePageView.swift
│   ├── PageCurlView.swift
│   ├── UsageMeterView.swift
│   ├── StarButton.swift
│   └── Components/
│       └── QuotaExceededSheet.swift
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

## Key Changes
- Splash screen is now gated on both minimum time and data readiness (movies/songs loaded)
- AppState manages splash/data readiness and navigation state
- MainTabView is deprecated; all navigation is in MelodyMapApp.swift
- Profile and paywall overlays use closure-based dismissal
- iOS 15: uses NavigationView; ready to migrate to NavigationStack for iOS 16+
