# Melody Map
Discover songs from your favorite kids' movies — fast.
Melody Map is a simple, visual-first app that helps parents, grandparents, babysitters, and caregivers quickly find, play, and enjoy songs from animated and live-action movies.

Built with scalability in mind, Melody Map starts with a clean search-driven experience and aims to grow into a smart, automated music discovery tool for families.

Features
🎵 Smart Song Search — instantly find any song with a single search bar

🎬 Movie Timeline View — see where each song appears in the movie with an intuitive timeline

📋 Manually Curated Content (initial version) — all songs are added and tagged by hand to ensure quality

🔍 Planned Future Enhancements:

automated metadata ingestion and smart tagging

support for non-song markers (key movie moments, quotes, etc.)

advanced search features (scene-based, mood-based, age-appropriate filters)

Target Audience
Primary: Parents with children ages 12 months to 7 years

Secondary: Grandparents, babysitters, and other caregivers

Platforms
iOS first

Android planned

Tech Stack
Frontend: Swift + SwiftUI for a native iOS experience

CMS (initial): Google Sheets

CMS (future scaling): Full database + admin UI once adoption scales

AI Support: OpenAI Codex assisting with coding tasks

Design Principles
One giant search bar for ease of use

Clean, visual-first timeline (inspired by polished streaming apps)

Fast, joyful interactions for busy caregivers

Minimalist UX — designed for quick lookups, not deep browsing

Development Goals
Build MVP using Google Sheets as CMS with a native SwiftUI app

Refine UX with visual timeline and instant search

Collect usage feedback and iterate

Prepare for scale: migrate to full database + automated ingest pipeline when appropriate

Project Status
✅ UX planning complete
✅ Initial architecture chosen
🚧 MVP development in progress
🗺️ Roadmap defined for automated future scaling

License
TBD — likely MIT or similar (to be finalized)

Credits
Concept + direction: Nathan Fisher

AI agent support: OpenAI Codex / GPT-4o

UX inspiration: top-tier kids apps, music discovery tools, and polished streaming platforms

## Project Structure

```
MelodyMap/
├── MelodyMapApp.swift
├── Assets.xcassets/
├── Info.plist
├── Resources/
├── Models/
├── Networking/
├── Views/
├── ViewModels/
├── Services/
├── Extensions/
├── Tests/
```

## Documentation
The full functional specification lives in [FUNCTIONAL_SPEC.md](FUNCTIONAL_SPEC.md).
Architecture details are described in [DESIGN_DOC.md](DESIGN_DOC.md).
