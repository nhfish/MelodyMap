# Melody Map · Functional Specification v1.2
_Last updated 2025-01-27_

---

## 1. Overview & Principles
* **Purpose** Help parents / caregivers instantly locate the start-time of Disney songs.
* **Aesthetic** Minimalist "storybook": gentle page-curls, soft shadows, tiny pixie sparkles, magical pixie burst transitions.
* **Tech Stack** Swift + SwiftUI · StoreKit 2 · Google AdMob (rewarded) · MusicKit (previews).
* **Offline-first** Song / Movie JSON cached on cold start; favorites & quota persist locally.

---

## 2. System 1 – Data Model & Source

| Item | Decision |
|------|----------|
| **Source** | Single Google Sheet **SongsData** tab |
| **Schema** | `MovieTitle` · `ReleaseYear` · `MovieRuntimeMin` · `SortOrder` · `ImageURL` · `SongTitle` · `Characters` (semicolon list) · `StartTime HH:MM:SS` · `StreamingLinks` (pipe list) · `PurchaseLinks` (pipe list) · `Keywords` · `Blurb` · `Token` |
| **Middleware** | Apps Script (`?token=…&mode=songs|movies`) |
| **Endpoints** | `/getSongs` → grouped Song objects with `percent` field   ·   `/getMovies` → unique Movie list sorted by `SortOrder` |
| **Auth** | `token=` param must equal hidden **Token** column |
| **Cache TTL** | 10 min (Apps Script cache) |
| **Offline** | JSON written to `Library/Caches`; read on next launch |

### Core Models

```swift
struct Song:  Identifiable, Codable {
    let id, movieId, title: String
    let percent: Int
    let startTime: String
    let singers: [String]
    let releaseYear, movieRuntimeMinutes: Int
    let streamingLinks, purchaseLinks, keywords: [String]
    let blurb: String
}

struct Movie: Identifiable, Codable {
    let id, title, imageURL: String
    let releaseYear, sortOrder: Int
}
```

## 3. System 2 – Navigation & Splash

| Aspect | Spec |
|--------|------|
| **Splash Screen** | Disney-style splash with pixie trail animation, minimum 2.5s display time |
| **Splash Gating** | Waits for both minimum time (2.5s) and data readiness (movies/songs loaded) |
| **Pixie Burst** | Magical particle animation when transitioning from splash to main app |
| **Home Screen** | SearchView serves as primary home screen with search functionality |
| **Navigation** | AppState-driven navigation with SearchView → TimelineView transitions |
| **Overlay System** | Profile and paywall appear as overlays with closure-based dismissal |

## 4. System 3 – Timeline Browsing

| Aspect | Spec |
|--------|------|
| Orientation | Portrait 9 × 16 |
| Page Controller | `UIPageViewController` with `.pageCurl` — **now locked to a single movie; users cannot swipe/curl to other movies** |
| Per-Movie Page | Poster · horizontal timeline line · snap-dots at % · arrow buttons left / right (only between songs in the same movie) |
| Song Navigation | Drag on timeline (magnetic snap) and arrow taps (within current movie only) |
| Collapsed Song Panel | Start Time (top) → divider → Song Title + ⭐ → Movie · Year → Characters |
| Expanded Panel | Streaming icons (Disney+ first) · Purchase icons · Blurb · Keywords · Share · reserved mini-preview slot |
| Movies w/o Songs | Excluded server-side |
| Sorting | `SortOrder` ascending |
| Favorites | `UserDefaults` array of `song.id` |
| Access | Via search results with smooth transitions |
| Arrow Navigation | Consumes a daily use and triggers the QuotaExceededSheet if out of quota |
| Timecode | Always formatted as HH:MM:SS |
| Release Year | Always shown without a comma |
| Preview Button | Unobtrusive play button next to timecode for Apple Music previews |

## 5. System 4 – Global Search

| Item | Spec |
|------|------|
| Omnibox | Top of Search tab; debounce 150 ms |
| Grouping | Results grouped by Movie, section expanded; best-match song row tinted |
| Bold Rule | Entire song title bold (no partial highlight) |
| Matching Fields | `songTitle`, `movieTitle`, `singers`, `keywords` |
| Fuzzy Logic | Levenshtein ≤ 2 plus Double Metaphone |
| Ranking | Exact prefix › substring › fuzzy › phonetic; Favorites +10 pts |
| Index | In-memory struct array (≤ 1.5 k songs) |
| Banner | Slim "Upgrade" banner pinned to bottom; hidden when subscribed |
| Navigation | Tap song → TimelineView with proper movie indexing |

## 6. System 5 – Song Detail View

Collapsed (default)

```
Start Time HH:MM:SS  ( % )
───────────────────────────
Song Title  ⭐
Movie · Year
Characters: Anna, Elsa
```

Expanded (tap "More")

```
Streaming icon row (Disney+ primary)
Purchase icon row
Blurb · Keywords · Share
Mini-audio placeholder (future)
```

Gesture / Dismiss: swipe ← / → or tap X → page-curl back.

## 7. System 6 – Daily Usage Limit + Rewarded Ads

| Parameter | Value |
|-----------|-------|
| Base free views / day | 3 Song Detail opens (updated from 10) |
| Free Re-watch Window | 15 minutes (viewing a song again within this window does not consume a use) |
| Reward | +2 views per 30 s rewarded ad |
| Daily cap | 15 views |
| Meter | Icon-only pill top-right ("n / 3" + progress ring); hides for subscribers |
| Quota Sheet | Cleaner UI (no usage bar/text), used for all quota-exceeded actions including arrow navigation |
| Cooldown | 30 s if ad aborted |
| Ad Limit | 6 rewarded ads / day |
| Persistence | UserDefaults with proper initialization |

## 8. System 7 – Subscription / IAP Flow

| Item | Spec |
|------|------|
| Products | `melodymap.monthly` $1.99 · 3-day trial   `melodymap.yearly` $14.99 · 3-day trial |
| Family Sharing | Enabled |
| Paywall Entry Points | Quota sheet · Search-tab bottom banner · Profile tab |
| Paywall Presentation | Presented as a standard, system-provided modal sheet using the `.sheet` modifier. |
| Paywall Bullets | "Unlimited song times" · "No ads or wait" · "Works fully offline" |
| StoreKit 2 | `PurchaseService` publishes `isSubscriber` → hides ads/meter, sets unlimited quota |

## 9. System 8 – Ad Integration

| Feature | Value |
|---------|-------|
| Network | Google AdMob rewarded |
| Tagging | Mixed-audience, COPPA compliant |
| Reward Flow | `AdService.presentAd()` → on reward → `UsageTracker.addRewarded(2)` |
| Failure Toasts | "Ad unavailable" or "Ad not completed" |
| Cap | 6 rewarded ads / day |

## 10. System 9 – MusicKit Preview Integration

| Feature | Value |
|---------|-------|
| Preview Length | 30 seconds (Apple Music standard) |
| Permission | Requested on first preview button tap |
| Search Strategy | Movie title + song title for optimal matching |
| UI Location | Unobtrusive button next to timecode in timeline |
| Controls | Simple tap-to-play, tap-to-stop |
| Fallback | Graceful hide if no preview available |
| Cleanup | Automatic when leaving view |
| Privacy | `NSAppleMusicUsageDescription` in main app Info.plist |

## 11. Services & Architecture Map

| Service | Duty |
|---------|-----|
| `APIService` | Fetch JSON → cache local |
| `TimelineViewModel` | Drive page controller, movie/song arrays |
| `SearchViewModel` | Build search index; return grouped hits |
| `SongDetailViewModel` | Expand / collapse panel; favorite toggle |
| `UsageTrackerService` | Quota count (3/day), daily reset, UserDefaults persistence |
| `FavoritesService` | Manages the list of favorited song IDs, persisted to UserDefaults. |
| `AdService` | Preload & present rewarded ads |
| `PurchaseService` | StoreKit 2 purchase / trial / restore |
| `MusicKitService` | Apple Music authorization, catalog search, preview URL retrieval |
| `AppState` | Navigation state, splash/data readiness, pixie burst coordination |

All service singletons injected via `.environmentObject`.

## 12. Animation & Accessibility

Default transition = page-curl (storybook).

Splash = pixie trail animation with minimum 2.5s display time.

Pixie burst = magical particle animation for splash-to-main transitions.

Paywall = standard system sheet presentation.

Reduce Motion → fall back to cross-fade.

Tap targets ≥ 44 pt; VoiceOver labels for timeline dots & icons.

## 13. Remote-Config Keys (future)

| Key | Default |
|-----|---------|
| `baseQuota` | 3 |
| `adRewardViews` | 2 |
| `dailyViewCap` | 15 |
| `monthlyPriceTier` | 1.99 |
| `yearlyPriceTier` | 14.99 |
| `freeTrialDays` | 3 |
| `adUnitID` | — |

## 14. Key Changes (v1.2)

- **Usage Quota:** Reduced from 10 to 3 views per day for better monetization
- **Navigation Architecture:** AppState-driven navigation with SearchView as home screen
- **Pixie Burst Animation:** Magical transition when moving from splash to main app
- **Splash Screen Gating:** Waits for both minimum time (2.5s) and data readiness
- **Daily Uses Counter:** Persistent tracking with proper initialization and UserDefaults
- **Search → Timeline Navigation:** Smooth transitions with proper movie indexing
- **Overlay System:** Profile and paywall use closure-based dismissal
- **Timeline Navigation:** Now strictly within a single movie (no accidental navigation to other movies)
- **Unified Quota Handling:** QuotaExceededSheet is shown consistently when out of daily uses, both in search and timeline
- **Improved UX:** Unified quota logic and modal handling for a seamless experience
- **Generous Free Tier:** Viewing a song unlocks it for a free 15-minute re-watch period.
- **Favorites System:** Users can now favorite songs, and access them from a dedicated list. The favorites button only appears when at least one song is favorited.
- **Arrow navigation in TimelineView now consumes a daily use and triggers the QuotaExceededSheet if out of quota**
- **QuotaExceededSheet is cleaner (no usage bar/text) and used for all quota-exceeded actions**
- **Profile button alignment is now visually consistent across views**
- **Timecode and release year formatting improved for clarity**
- **MusicKit Integration:** Apple Music previews with 30-second previews, on-demand permission requests, and simple play/stop controls
- **Preview Button UI:** Unobtrusive preview buttons next to timecodes in timeline view
- **Audio Preview Player:** Simple audio playback component with proper memory management
- **Privacy Compliance:** Proper NSAppleMusicUsageDescription in main app Info.plist

_End of Spec_

