# Melody Map · Functional Specification v1.0
_Last updated 2025-06-13_

---

## 1. Overview & Principles
* **Purpose** Help parents / caregivers instantly locate the start-time of Disney songs.
* **Aesthetic** Minimalist “storybook”: gentle page-curls, soft shadows, tiny pixie sparkles.
* **Tech Stack** Swift + SwiftUI · StoreKit 2 · Google AdMob (rewarded).
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

## 3. System 2 – Timeline Browsing

| Aspect | Spec |
|--------|------|
| Orientation | Portrait 9 × 16 |
| Page Controller | `UIPageViewController` with `.pageCurl` |
| Per-Movie Page | Poster · horizontal timeline line · snap-dots at % · arrow buttons left / right |
| Song Navigation | Drag on timeline (magnetic snap) and arrow taps |
| Collapsed Song Panel | Start Time (top) → divider → Song Title + ⭐ → Movie · Year → Characters |
| Expanded Panel | Streaming icons (Disney+ first) · Purchase icons · Blurb · Keywords · Share · reserved mini-preview slot |
| Movies w/o Songs | Excluded server-side |
| Sorting | `SortOrder` ascending |
| Favorites | `UserDefaults` array of `song.id` |

## 4. System 3 – Global Search

| Item | Spec |
|------|------|
| Omnibox | Top of Search tab; debounce 150 ms |
| Grouping | Results grouped by Movie, section expanded; best-match song row tinted |
| Bold Rule | Entire song title bold (no partial highlight) |
| Matching Fields | `songTitle`, `movieTitle`, `singers`, `keywords` |
| Fuzzy Logic | Levenshtein ≤ 2 plus Double Metaphone |
| Ranking | Exact prefix › substring › fuzzy › phonetic; Favorites +10 pts |
| Index | In-memory struct array (≤ 1.5 k songs) |
| Banner | Slim “Upgrade” banner pinned to bottom; hidden when subscribed |

## 5. System 4 – Song Detail View

Collapsed (default)

```
Start Time HH:MM:SS  ( % )
───────────────────────────
Song Title  ⭐
Movie · Year
Characters: Anna, Elsa
```

Expanded (tap “More”)

```
Streaming icon row (Disney+ primary)
Purchase icon row
Blurb · Keywords · Share
Mini-audio placeholder (future)
```

Gesture / Dismiss: swipe ← / → or tap X → page-curl back.

## 6. System 5 – Daily Usage Limit + Rewarded Ads

| Parameter | Value |
|-----------|-------|
| Base free views / day | 3 Song Detail opens |
| Reward | +2 views per 30 s rewarded ad |
| Daily cap | 15 views |
| Meter | Icon-only pill top-right (“n / 3” + progress ring); hides for subscribers |
| Quota Sheet | Page-curl modal: Watch Ad (+2) · Go Unlimited · Not Now |
| Cooldown | 30 s if ad aborted |
| Ad Limit | 6 rewarded ads / day |

## 7. System 6 – Subscription / IAP Flow

| Item | Spec |
|------|------|
| Products | `melodymap.monthly` $1.99 · 3-day trial   `melodymap.yearly` $14.99 · 3-day trial |
| Family Sharing | Enabled |
| Paywall Entry Points | Quota sheet · Search-tab bottom banner · Profile tab |
| Paywall Animation | Pixie flies in → castle glyph glows centre-screen → floating blurred sheet appears; reverse on dismiss |
| Paywall Bullets | “Unlimited song times” · “No ads or wait” · “Works fully offline” |
| StoreKit 2 | `PurchaseService` publishes `isSubscriber` → hides ads/meter, sets unlimited quota |

## 8. System 7 – Ad Integration

| Feature | Value |
|---------|------|
| Network | Google AdMob rewarded |
| Tagging | Mixed-audience, COPPA compliant |
| Reward Flow | `AdService.presentAd()` → on reward → `UsageTracker.addRewarded(2)` |
| Failure Toasts | “Ad unavailable” or “Ad not completed” |
| Cap | 6 rewarded ads / day |

## 9. Services & Architecture Map

| Service | Duty |
|---------|-----|
| `APIService` | Fetch JSON → cache local |
| `TimelineViewModel` | Drive page controller, movie/song arrays |
| `SearchViewModel` | Build search index; return grouped hits |
| `SongDetailViewModel` | Expand / collapse panel; favorite toggle |
| `UsageTrackerService` | Quota count, daily reset |
| `AdService` | Preload & present rewarded ads |
| `PurchaseService` | StoreKit 2 purchase / trial / restore |

All service singletons injected via `.environmentObject`.

## 10. Animation & Accessibility

Default transition = page-curl (storybook).

Paywall = pixie + centre-sheet fade / blur.

Reduce Motion → fall back to cross-fade.

Tap targets ≥ 44 pt; VoiceOver labels for timeline dots & icons.

## 11. Remote-Config Keys (future)

| Key | Default |
|-----|---------|
| `baseQuota` | 3 |
| `adRewardViews` | 2 |
| `dailyViewCap` | 15 |
| `monthlyPriceTier` | 1.99 |
| `yearlyPriceTier` | 14.99 |
| `freeTrialDays` | 3 |
| `adUnitID` | — |

_End of Spec_

