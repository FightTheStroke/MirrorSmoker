# Implementation Roadmap: MirrorSmokerStopper (iOS 17+ / watchOS 8+)
**Version 3.0 - Detailed Technical Blueprint**

## 1. Vision & Architecture

This document serves as the technical guide to transform **MirrorSmokerStopper** into a cutting-edge, motivational, and intelligent companion for quitting smoking. The goal is an application that is **beautiful to use**, **highly effective**, and fully leverages the technological capabilities of **iOS 26** and **watchOS 12**, while maintaining robust backward compatibility.

### 1.1. Navigation & App Structure Redesign
The app's navigation will be reorganized to better reflect the user's journey:
- **Tab 1: "Today" (`TodayView`, formerly `ContentView`)**: The dynamic dashboard for daily actions, insights, and motivation.
- **Tab 2: "Progress" (`ProgressView`, formerly `StatisticsView`)**: A visual narrative of the user's success, health benefits, and behavioral patterns.
- **Tab 3: "Plan & Profile" (`PlanView`, formerly `SettingsView`)**: The personal control center for defining strategies, motivations, and configuring the AI Coach.

### 1.2. Design and Interaction Principles
- **Liquid Glass & Depth:** The UI will shift from solid backgrounds to translucent materials (`.liquidGlassBackground`), creating a sense of depth and context. Cards and controls will appear to float above a blurred background.
- **Micro-interactions & Haptics:** Every significant tap, swipe, and milestone will be accompanied by haptic feedback (`UIImpactFeedbackGenerator`) and fluid animations (`DS.Animation.glass`), making the app feel alive and responsive.
- **SF Symbols 7:** Use of animated and hierarchically rendered symbols to provide emphasis and communicate status more effectively.

---

## 2. Phase 1: Foundational Project Updates

### 2.1. Project Configuration
- **iOS Target:** `Base SDK: Latest iOS (iOS 26)`, `Deployment Target: 17.0`.
- **watchOS Target:** `Base SDK: Latest watchOS (watchOS 12)`, `Deployment Target: 8.0`.
- **Code:** Extensive use of `#available` checks for feature-gating.

### 2.2. Design System (`DS`) Enhancement for iOS 26
- **File: `Utilities/DesignSystem.swift`**
  - **Colors:** Add a palette for glass effects (e.g., `glassPrimary: Color.white.opacity(0.4)`).
  - **View Extension:** Implement a `.liquidGlassBackground()` modifier that applies a `UIVisualEffectView` (blur) with a subtle border to emulate the glass effect.
- **File: `Utilities/DesignSystemComponents.swift`**
  - **`DSCard`:** Add a `.glass` variant that uses the new modifier.
  - **New Components:** Define stubs for new UI components: `MilestoneCardView`, `HealthBenefitChartView`, `SavingsGoalView`.

### 2.3. Privacy & Capabilities
- **`MirrorSmokerStopper.entitlements`**: Enable **HealthKit**.
- **`Info.plist`**: Add usage descriptions for HealthKit.
- Implement the system's permission request for notifications on app startup.

---

## 3. Phase 2: UI/UX Redesign of Core Views

### 3.1. Redesign "Plan & Profile" (`PlanView`)
**Goal:** Transform the settings screen into a personal, motivational hub where users actively manage their quit journey.

- **Layout:** A `ScrollView` containing a `VStack(spacing: .lg)`.
- **Components:**
  - **1. `ProfileHeaderView`:** A card with an avatar, name, and a prominent `TextEditor` for **"My Why"**—the user's core motivation, which will be used by the AI Coach.
  - **2. `DSCard(variant: .glass)` for "My Quit Plan":**
    - `DatePicker` for the quit date.
    - A segmented `Picker` for "Cold Turkey" vs. "Gradual Reduction".
    - If gradual, display an interactive `ChartView` (using Swift Charts) showing the reduction curve.
  - **3. `DSCard(variant: .glass)` for "AI Coach" (`#if available(iOS 26, *)`):**
    - A `Toggle` to enable/disable the coach.
    - Clear, transparent text explaining its on-device, privacy-first nature.
    - A `NavigationLink` to configure "Quiet Hours".
  - **4. `DSCard(variant: .glass)` for "Connected Services":**
    - A list of `Toggle`s for each HealthKit data type (sleep, activity, medications), with an explanation of why each is useful.

### 3.2. Redesign "Progress" (`ProgressView`)
**Goal:** Tell a visual and motivational story of the user's journey.

- **Layout:** A `ScrollView` containing a `LazyVStack`.
- **Components:**
  - **1. Horizontal Carousel of `MilestoneCardView`:** A `ScrollView(.horizontal)` displaying unlocked achievements (e.g., "24 Hours Smoke-Free," "100 Cigarettes Avoided," "$50 Saved").
  - **2. `DSCard(variant: .glass)` "Health Regained":**
    - A `TabView(style: .page)` to swipe through different health benefit charts.
    - Use animated SF Symbols (e.g., `lungs.fill` with a `.symbolEffect`) to make the view dynamic.
  - **3. `DSCard(variant: .glass)` "Financial Savings":**
    - A `SavingsGoalView` with a progress bar filling up towards a user-defined goal.
  - **4. `DSCard(variant: .glass)` "Craving Analysis":**
    - A weekly **Heatmap** (`LazyVGrid`) showing days and hours with the most intense cravings.
    - A horizontal **Bar Chart** (`Swift Charts`) showing the top 3 triggers (tags) to help users identify their main challenges.

### 3.3. Modernize "Today" (`TodayView`)
**Goal:** Provide a clear, actionable summary of the day.

- **Layout:** `ScrollView` with a `VStack`.
- **Components:**
  - **1. `HeroHeaderView`:** Greeting, user name, `DSProgressRing` for the daily target, and a prominent display of "Time since last cigarette."
  - **2. `DSCard(variant: .glass)` "Coach's Tip of the Day" (`#if available(iOS 26, *)`):** Displays the AI-generated tip or a static one.
  - **3. `TodayCigarettesList`:** The list of today's cigarettes, styled with `.liquidGlass`.
  - **4. Floating Action Button:** A `DSFloatingActionButton` with `+`.
    - **Long Press:** Activates a `.contextMenu` for quick actions like `LogUrgeIntent` or "I need support."

---

## 4. Phase 3: AI Coach Implementation (iOS 26 Only)

Implementation follows `AiPoweredToDo.md`.
- **UI:** AI tips will appear in `TodayView` and as JITAI notifications. Opt-in and configuration are in `PlanView`.
- **Widgets & Live Activities:** The Lock/Home Screen widget shows the daily tip and a button for `GetCoachTipIntent`. A Live Activity can be started to guide the user through a 5-minute craving with breathing exercises.

---

## 5. Phase 4: watchOS Modernization (watchOS 8+ / 12+)

- **App Architecture (watchOS 12+):**
  - A `TabView` with three screens:
    1. **Log:** A progress ring and a large button to log a cigarette.
    2. **Stats:** Quick stats (today's count, time since last).
    3. **Coach:** The daily AI tip, if available.
- **Complications (watchOS 12+):**
  - **`.circular`:** A `Gauge` showing daily progress.
  - **`.rectangular`:** Displays the time since the last cigarette and the AI tip.
  - **Interactivity:** Tapping a complication can trigger `LogUrgeIntent`.
- **Data Integration:** Use `WatchConnectivity` to send real-time data (e.g., Heart Rate during a logged urge) to the iPhone's `FeatureStore` to improve predictions.

---

## 6. Phase 5: Advanced Efficacy Enhancements

Integrate powerful behavioral science techniques to maximize the app's effectiveness.

### 6.1. Gamification: "The Wellness Journey"
- **What:** A visual map or path in the **"Progress"** tab. Each smoke-free day moves the user forward, unlocking rewards and "rest stations" corresponding to health milestones.
- **Why (Psychology):** Breaks down the daunting goal of quitting into manageable daily steps, providing positive reinforcement and a strong sense of progress.
- **Implementation:** Create a new `JourneyView` within the `ProgressView`.

### 6.2. Social Support: "Your Support Circle"
- **What:** A private, opt-in feature in the **"Plan & Profile"** tab where a user can invite 1-3 trusted people. A "Need Support" button in the app sends a pre-defined, discrete notification to this circle.
- **Why (Psychology):** Provides just-in-time social support, increases accountability, and combats the feeling of isolation.
- **Implementation:** Requires careful privacy controls. Use `CloudKit` to manage the private sharing of support requests.

### 6.3. Cognitive Tools (CBT): "The Thought Diary"
- **What:** When a user logs an urge, the app offers an optional prompt based on Cognitive Behavioral Therapy, e.g., "What thought triggered this craving? Is it a fact or a feeling?"
- **Why (Psychology):** Teaches users to recognize, challenge, and reframe the automatic negative thoughts that lead to smoking (Cognitive Restructuring).
- **Implementation:** Extend the `LogUrgeIntent` flow. User responses are stored locally and can be used by the AI Coach on iOS 26 to personalize tips about thought patterns.

### 6.4. Proactive AI: "Predictive Trigger Analysis"
- **What:** An evolution of the AI Coach. After a learning period, the `CoachEngine` starts predicting high-risk moments and sends proactive notifications *before* they happen. E.g., _"The time after lunch is often a challenge. Let's make a plan..."_
- **Why (Psychology):** Moves from reactive support to proactive relapse prevention, empowering the user and increasing their sense of self-efficacy.
- **Implementation:** Requires enhancing the `CoachEngine`'s algorithms to include predictive logic, without changing the UI significantly.

---

## 7. Phase 6: Testing and Validation

- **Unit & Integration Tests:** Cover `CoachEngine`, `HealthKitManager`, and `#available` feature-gating logic.
- **UI & Compatibility Testing:** Test on **iOS 17 & 26** simulators and devices. Test on **watchOS 8 & 12**.
- **Usability Testing:** Gather feedback on the new UI's clarity, beauty, and motivational impact.
- **Release Checklist:** Verify `Info.plist`, entitlements, and ensure no un-gated APIs are called on older OS versions.