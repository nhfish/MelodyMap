# Melody Map
Discover songs from your favorite kids' movies — fast.
Melody Map is a simple, visual-first app that helps parents, grandparents, babysitters, and caregivers quickly find, play, and enjoy songs from animated and live-action movies.

Built with scalability in mind, Melody Map starts with a clean search-driven experience and aims to grow into a smart, automated music discovery tool for families.

## Features
🎵 **Smart Song Search** — instantly find any song with a single search bar

🎬 **Movie Timeline View** — see where each song appears in the movie with an intuitive timeline

📋 **Manually Curated Content** — all songs are added and tagged by hand to ensure quality

🎯 **Usage Tracking** — daily limits with extension options (currently using mock ad system)

## Current Development Status

### ✅ **Completed**
- Core app architecture with SwiftUI
- Google Sheets integration via Apps Script
- Search functionality with fuzzy matching
- Timeline view with page transitions
- Usage tracking system
- Mock ad system for development testing

### 🚧 **In Progress**
- UI polish and refinement
- User experience optimization
- Content management system

### 📋 **Planned**
- Google Ads integration (temporarily disabled)
- In-app purchase system
- Advanced search features
- Content expansion

## Technical Notes

### Google Ads Integration
Google Ads integration is temporarily disabled during development to focus on core functionality. The system uses a mock implementation that simulates successful ad views for testing purposes. This allows development to continue without SDK compatibility issues.

**To re-enable Google Ads later:**
1. Update to a compatible SDK version (v9.x series recommended for iOS 15.2)
2. Uncomment the Google Mobile Ads implementation
3. Re-add the framework to the project
4. Test with actual ad units

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
✅ UX planning complete  
✅ Initial architecture chosen  
✅ Core functionality implemented  
🚧 UI polish and refinement in progress  
📋 Google Ads integration planned (temporarily disabled)  
🗺️ Roadmap defined for automated future scaling  

## Project Structure

```
MelodyMap/
├── MelodyMapApp.swift          # App entry point
├── Assets.xcassets/            # App icons and images
├── Info.plist                  # App configuration
├── Resources/                  # Static resources
├── Models/                     # Data models
│   ├── Song.swift
│   ├── Movie.swift
│   ├── UserProfile.swift
│   └── IndexedSong.swift
├── Networking/                 # API and data services
│   ├── APIService.swift
│   └── GoogleSheetsService.swift
├── Views/                      # SwiftUI views
│   ├── MainTabView.swift
│   ├── TimelineView.swift
│   ├── SearchView.swift
│   ├── ProfileView.swift
│   ├── SongDetailView.swift
│   ├── MoviePageView.swift
│   ├── PageCurlView.swift
│   ├── UsageMeterView.swift
│   └── StarButton.swift
├── ViewModels/                 # View models
│   ├── TimelineViewModel.swift
│   ├── SearchViewModel.swift
│   └── UserProfileViewModel.swift
├── Services/                   # Business logic services
│   ├── AdService.swift         # (Currently disabled)
│   ├── UsageTrackerService.swift
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
