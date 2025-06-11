Melody Map — Project Summary for AI Agent

## Project Goal
Melody Map is an iOS-first app that helps parents and caregivers easily find and play songs from Disney movies and related content.
The app provides a visual movie timeline and a simple search interface to discover and access songs, optimized for fast, delightful mobile experiences.

## Target Platforms
- iOS first (iPhone + iPad)
- Android support considered after initial launch

## Visual / UX Goals
- Sleek, modern, App Store-quality polish
- Smooth animations and transitions (timeline scrolling, fades, subtle scaling)
- Crisp text and clear UI hierarchy
- Light visual flair (drop shadows, parallax layers, animated cards), but not a game-like experience
- Accessibility-friendly (supporting older caregivers / parents)

## Features MVP
- Movie timeline view with clickable movie entries
- Smart search field (global search of song titles, movies, characters, keywords)
- Song list results with metadata (streaming links, purchase links, keywords, release year, runtime)
- Basic user profile for tracking usage limits
- Daily free use limit with ad-reward flow to extend usage
- In-app purchase:
  - Monthly subscription
  - Yearly subscription
- Basic settings screen

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
- Networking layer (Google Sheets API integration → JSON parsing)
- IAP setup with StoreKit 2
- Ad integration (AdMob preferred but flexible)
- Animations and subtle visual effects

Backend is initially Google Sheets, to be migrated to a database + admin UI if app scales

## Constraints / Guidance
- App must feel fast, native, and lightweight
- App must be App Store compliant (proper IAP and ad flows)
- UI should follow iOS HIG (Human Interface Guidelines)
- No Unity, no game engine — this is a native app with a content-driven UX
- All animations should feel natural and performant on iPhone hardware
