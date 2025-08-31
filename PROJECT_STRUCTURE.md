# Mirror Smoker - Project Structure

This document describes the reorganized project structure for the Mirror Smoker app, following the principle that each file should be under 250 lines for better maintainability.

## Directory Structure

```
MirrorSmoker/
├── Models/                          # Data models and SwiftData entities
│   ├── Cigarette.swift             # Main cigarette model (37 lines)
│   ├── Tag.swift                   # Tag model for categorization (27 lines)
│   ├── Tag+Extensions.swift        # Tag extensions and utilities (41 lines)
│   ├── UserProfile.swift           # User preferences and settings (33 lines)
│   └── Product.swift               # Cigarette brand/product info (36 lines)
│
├── Views/                           # UI components organized by feature
│   ├── Common/                     # Shared UI components
│   │   ├── ContentView.swift       # Main content view (299 lines)
│   │   ├── DailyStatsHeader.swift  # Today's statistics header (75 lines)
│   │   ├── TodayCigarettesList.swift # List of today's cigarettes (65 lines)
│   │   ├── HistorySection.swift    # Historical data section (53 lines)
│   │   ├── QuickStatsFooter.swift  # Footer with compact stats (136 lines)
│   │   ├── FloatingActionButton.swift # FAB for adding cigarettes (51 lines)
│   │   ├── TagPickerView.swift     # Tag selection interface (138 lines)
│   │   ├── AdvancedAnalyticsView.swift # Advanced analytics (174 lines)
│   │   ├── SettingsView.swift      # macOS settings window (105 lines)
│   │   └── WatchContentView.swift  # Apple Watch interface (171 lines)
│   │
│   ├── Statistics/                 # Statistics and analytics views
│   │   ├── StatisticsView.swift    # Main statistics view (95 lines)
│   │   ├── GeneralStatsSection.swift # General stats section (45 lines)
│   │   ├── StatCard.swift          # Individual stat display (48 lines)
│   │   ├── WeeklyChart.swift       # Weekly statistics chart (63 lines)
│   │   ├── WeeklyStatsView.swift   # Weekly statistics detail (235 lines)
│   │   └── DayDetailView.swift     # Daily detail view (155 lines)
│   │
│   └── Widgets/                    # Widget-related components
│       ├── CigaretteWidget.swift   # iOS widget implementation (89 lines)
│       └── AddCigaretteIntent.swift # Siri shortcuts and intents (67 lines)
│
├── Utilities/                       # Helper utilities and extensions
│   └── AppColors.swift             # App color definitions (34 lines)
│
├── Resources/                       # Localization and assets
│   ├── Localizable.strings (English) # English localization (41 lines)
│   └── Localizable.strings (Italian) # Italian localization (41 lines)
│
├── Assets.xcassets/                 # App icons and images
├── MirrorSmokerApp.swift            # Main app entry point (52 lines)
└── PROJECT_STRUCTURE.md             # This file
```

## Key Principles

### 1. File Size Limit
- **Maximum 250 lines per file**: All files are kept under this limit for better readability and maintainability
- **Component-based architecture**: Large views are broken down into smaller, focused components

### 2. Separation of Concerns
- **Models**: Pure data models with SwiftData annotations
- **Views**: UI components organized by feature area
- **ViewModels**: Business logic separated from UI
- **Utilities**: Reusable helper functions and extensions

### 3. Feature Organization
- **Common**: Shared components used across multiple features
- **Statistics**: All statistics and analytics-related views
- **Widgets**: Widget implementations and Siri shortcuts

### 4. Data Flow
- **SwiftData**: CloudKit-backed data persistence
- **@Query**: Reactive data binding
- **@StateObject**: View model management
- **@Environment**: Dependency injection

## Benefits of This Structure

1. **Maintainability**: Smaller files are easier to understand and modify
2. **Reusability**: Components can be reused across different views
3. **Testability**: Smaller components are easier to unit test
4. **Collaboration**: Multiple developers can work on different components simultaneously
5. **Performance**: Lazy loading and better memory management
6. **Scalability**: Easy to add new features without affecting existing code

## Adding New Features

When adding new features:

1. **Create new models** in the `Models/` directory
2. **Create new views** in appropriate feature directories
3. **Keep files under 250 lines** by breaking down complex views
4. **Follow naming conventions** for consistency
5. **Update this documentation** to reflect changes

## Migration Notes

The project was reorganized from a flat structure to this hierarchical organization. All imports and references have been updated to reflect the new structure. The main app file (`MirrorSmokerApp.swift`) remains in the root directory as it's the entry point.
