# Roadmap

This document outlines the plan to implement and iterate on Mirror Smoker.

## Milestone 1 — Foundations
- [x] SwiftData models: Cigarette, Tag, UserProfile, Product
- [x] CloudKit SwiftData configuration
- [x] Tagging UI (TagPicker) with create/select and color palette
- [x] Show tags in today’s list as colored chips
- [x] Swipe right (leading) on a row to add/edit tags
- [x] Delete entry with swipe left (trailing)
- [x] Realtime sync (iOS ↔︎ watchOS) for add/delete and tag upsert via ConnectivityManager
- [x] Advanced Analytics (weekday/hour/tag)
- [x] Localization EN/IT (initial keys; to expand)
- [x] App Intents (AddCigaretteIntent)
- [x] Widget (today’s count + add button)
- [x] Watch app target (wire existing WatchContentView)

Notes:
- Tag synchronization: ConnectivityManager performs upsert when a CigaretteDTO arrives, resolving/creating tags by name and assigning relationships.
- Tag creation is immediately persisted via SwiftData and reflected by @Query in ContentView.
- WidgetStore manages snapshots (today count + last time) and an inbox for quick add.

Remaining open tasks for M1:
- [ ] Expand localization for new UI strings (TagPicker: “Create New Tag”, “Select Tags”, “Add Tag”, “Cancel”, “Done”; AdvancedAnalytics; WatchContentView)
- [ ] End-to-end verification of bidirectional sync with tags on real devices (iOS ↔︎ watchOS)

## Milestone 2 — Profile & Catalog
- [ ] ProfileView (birthdate, sex, preferred products)
- [ ] ProductPicker with curated dataset; custom items
- [ ] Image assets for common products
- [ ] Sign in with Apple (profile binding)

## Milestone 3 — Siri & Shortcuts Enhancements
- [ ] More natural phrases (EN/IT) and parameters for tags
- [ ] Shortcut donations on key actions
- [ ] Intent for quick add with multiple tags and a note

## Milestone 4 — Gamification & Insights
- [ ] Motivation Engine: initial dataset (messages/scenarios)
- [ ] Motivation Engine: basic message selection logic
- [ ] Streaks, trends, reduction goals
- [ ] Recommendations and reminders based on tags

## Milestone 5 — Widget & Watch Improvements
- [ ] Widget: parameters/actions with tags from the widget
- [ ] Widget: snapshot/timeline optimizations on data changes
- [ ] watchOS: complication (optional)
- [ ] watchOS: quick stats and additional micro-interactions

## Milestone 6 — Polish & QA
- [ ] Accessibility pass (VoiceOver, Dynamic Type, colors)
- [ ] Performance tuning (queries, list rendering, Charts)
- [ ] Tests (Swift Testing): unit and UI smoke tests
- [ ] Store metadata (if distribution is planned)

## Tests & Quality (cross-cutting)
- [ ] Test ConnectivityManager: upsert/merge with tags (Swift Testing)
- [ ] Test WidgetStore: snapshot/inbox and round-trip with ContentView
- [ ] Test TagPicker: create/select/deselect, persistence
- [ ] Test AdvancedAnalytics: hourly/weekly/tag aggregations

Open Tasks / Next Steps
- [ ] Verify real-time bidirectional sync including tags on iOS and watchOS (physical devices)
- [ ] Expand localization keys for new UI strings (e.g., “Add Tag”, “Select Tags”, “Create New Tag”, “Advanced Analytics”, Watch strings)
- [ ] Add tests for ConnectivityManager upsert/merge logic with tags using Swift Testing
- [ ] Evaluate watchOS complication and intent/widget with tag parameters
- [ ] Plan Sign in with Apple and profile binding (Milestone 2)
