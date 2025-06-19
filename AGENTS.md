Melody Map — Project Summary for AI Agent

## Project Goal
Melody Map is an iOS-first app that helps parents and caregivers easily find and play songs from Disney movies and related content.
The app provides a visual movie timeline and a simple search interface to discover and access songs, optimized for fast, delightful mobile experiences with magical pixie burst animations.

## Target Platforms
- iOS first (iPhone + iPad)
- Android support considered after initial launch

## Visual / UX Goals
- Sleek, modern, App Store-quality polish
- Smooth animations and transitions (timeline scrolling, fades, subtle scaling, pixie burst effects)
- Crisp text and clear UI hierarchy
- Light visual flair (drop shadows, parallax layers, animated cards, magical transitions), but not a game-like experience
- Accessibility-friendly (supporting older caregivers / parents)

## Features MVP
- **Navigation Architecture:** AppState-driven navigation with SearchView as home screen
- **Splash Screen:** Disney-style splash with pixie trail animation and minimum 2.5s display time
- **Pixie Burst Animation:** Magical transition when moving from splash to main app
- **Movie Timeline View:** Clickable movie entries accessed via search results
- **Smart Search Field:** Global search of song titles, movies, characters, keywords
- **Song List Results:** Metadata (streaming links, purchase links, keywords, release year, runtime)
- **Usage Tracking:** Daily free use limit (3 views/day) with ad-reward flow to extend usage
- **Daily Uses Counter:** Persistent tracking with proper initialization and UserDefaults
- **In-app Purchase:**
  - Monthly subscription
  - Yearly subscription
- **Profile Overlay:** Settings screen with usage stats and subscription status

## Data Model (MVP)
Songs dataset is initially sourced from a Google Sheet → parsed into app. Each song entry includes:
- Movie title
- Song title
- Singer(s)
- Start time in movie
- Release year
- Total movie runtime
- Streaming link(s)
- Purchase link(s)
- Keywords
- Blurb / description

## Tech Stack
Xcode project using Swift + SwiftUI

Codex agent assists with:
- SwiftUI component generation
- ViewModel patterns
- Navigation architecture (AppState-driven)
- Networking layer (Google Sheets API integration → JSON parsing)
- IAP setup with StoreKit 2
- Ad integration (AdMob preferred but flexible)
- Animations and subtle visual effects (pixie burst, page curls)
- Usage tracking with UserDefaults persistence

Backend is initially Google Sheets, to be migrated to a database + admin UI if app scales

## Current Architecture
- **AppState:** Centralized navigation and splash/data readiness management
- **SearchView:** Primary home screen with search functionality
- **TimelineView:** Accessed via search results with smooth transitions
- **UsageTrackerService:** Tracks daily quota (3 views/day) with proper persistence
- **Overlay System:** Profile and paywall use closure-based dismissal
- **Pixie Burst:** Magical particle animation for splash-to-main transitions

## Constraints / Guidance
- App must feel fast, native, and lightweight
- App must be App Store compliant (proper IAP and ad flows)
- UI should follow iOS HIG (Human Interface Guidelines)
- No Unity, no game engine — this is a native app with a content-driven UX
- All animations should feel natural and performant on iPhone hardware
- Navigation should be intuitive with SearchView as the primary entry point
- Usage tracking should be persistent and properly initialized
