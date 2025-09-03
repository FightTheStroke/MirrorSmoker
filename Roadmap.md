# Implementation Roadmap: MirrorSmokerStopper (iOS 17+ / watchOS 8+)
**Version 4.0 - Full Technical & Business Blueprint**

## 1. Vision & Architecture

This document is the technical and product guide to transform **MirrorSmokerStopper** into a state-of-the-art, motivational, and intelligent companion for quitting smoking. The goal is an app that is **beautiful to use**, **highly effective**, and fully leverages the technological capabilities of **iOS 26** and **watchOS 12**, while maintaining a sustainable business model.

### 1.1. Monetization Strategy: Freemium Model
Based on industry best practices for wellness and habit-change apps, we will adopt a **Freemium** model. This provides a powerful, free-forever core experience to all users, with an optional subscription (`MirrorSmokerStopper Pro`) that unlocks advanced, highly personalized features.

- **Free Tier (Core App):** Provides all essential tools for tracking and basic progress monitoring. The goal is to deliver genuine value and build user trust.
- **Premium Tier (Pro Subscription):** Offers advanced AI-powered coaching, deep analytics, and powerful motivational tools for users who are highly committed and want the best possible support system.

### 1.2. Navigation & App Structure Redesign
The app's navigation will be reorganized to support the freemium model and improve user flow:
- **Tab 1: "Today" (`TodayView`)**: The daily dashboard.
- **Tab 2: "Progress" (`ProgressView`)**: The visual story of the user's success.
- **Tab 3: "Plan & Profile" (`PlanView`)**: The personal control center.

---

## 2. Phase 1: Foundational Project Updates

### 2.1. Project Configuration
- **iOS Target:** `Base SDK: Latest iOS (iOS 26)`, `Deployment Target: 17.0`.
- **watchOS Target:** `Base SDK: Latest watchOS (watchOS 12)`, `Deployment Target: 8.0`.

### 2.2. Design System (`DS`) Enhancement for iOS 26
- **File: `Utilities/DesignSystem.swift`**: Implement the `.liquidGlassBackground()` modifier.
- **File: `Utilities/DesignSystemComponents.swift`**: Add a `.glass` variant to `DSCard` and update all components to support the new aesthetic.

### 2.3. Privacy & Capabilities
- **`MirrorSmokerStopper.entitlements`**: Enable **HealthKit**.
- **`Info.plist`**: Add usage descriptions for HealthKit and Notifications.

---

## 3. Phase 2: Core Experience & UI/UX Redesign (Free Tier)

This phase focuses on building a best-in-class free experience.

### 3.1. New Core Feature: Cost & Purchase Tracking
- **Goal:** Allow users to track their spending on tobacco products to make the "Financial Savings" metric accurate and impactful.
- **Implementation:**
  - **Data Model:** Extend `SwiftData` with a `Purchase` model (`date: Date`, `amountInCents: Int`, `currencyCode: String`, `productName: String`, `quantity: Int`).
  - **Intents:** Create a `LogPurchaseIntent` for quick logging via Shortcuts or Siri.
  - **UI:** Add a "Log Purchase" button in the `TodayView`, accessible through the FAB context menu. The financial data will directly feed the "Savings" card.
  - **Status:** ✅ Implemented

### 3.2. Redesign "Plan & Profile" (`PlanView`)
- **Components:**
  - **1. `ProfileHeaderView`:** User's name and their core motivation ("My Why").
  - **2. `DSCard(variant: .glass)` for "My Quit Plan":** Quit date and method setup.
  - **3. `DSCard(variant: .glass)` "Upgrade to Pro":** A visually appealing, non-intrusive card that clearly communicates the benefits of the Pro subscription. Tapping it will present the paywall.
  - **4. `DSCard(variant: .glass)` for "Connected Services":** HealthKit permission management.

### 3.3. Redesign "Progress" (`ProgressView`)
- **Components:**
  - **1. `MilestoneCarouselView`:** A horizontal carousel celebrating key achievements (e.g., "24 Hours Smoke-Free"). **The first few milestones are free; advanced ones are a Pro feature.**
  - **2. `DSCard(variant: .glass)` "Financial Savings":** A clear view of money saved, now based on actual user-inputted purchase data.
  - **3. `DSCard(variant: .glass)` "General Trend":** A simple line chart showing cigarettes per day for the last 7 days. **(Advanced analytics are Pro).**

### 3.4. Modernize "Today" (`TodayView`)
- **Components:**
  - **1. `HeroHeaderView`:** Daily progress ring and time since last cigarette.
  - **2. `TodayCigarettesList`:** The core tracking list.
  - **3. `DSCard(variant: .glass)` showing a static, curated "Tip of the Day" from a local library.** (AI tips are Pro).

---

## 4. Phase 3: Monetization & Business Logic

### 4.1. StoreKit Integration
- **Implementation:**
  - Integrate `StoreKit 2` to manage subscriptions (`monthly` and `yearly` options) and one-time purchases.
  - Create a `StoreManager` class to handle transactions, validate receipts, and check subscription status.
  - Implement a secure way to store the user's premium status locally (e.g., `UserDefaults` or a secure keychain entry).

### 4.2. Paywall UI
- **Goal:** Design a beautiful, compelling, and transparent paywall.
- **Implementation:**
  - Create a `PaywallView` presented modally.
  - **Content:**
    - A clear headline: "Unlock Your Full Potential with MirrorSmokerStopper Pro".
    - A bulleted list of Pro features, each with a clear icon and benefit-driven description (e.g., "Personalized AI Coach," "Deep Health Analytics").
    - Social proof or testimonials (if available).
    - Clear pricing for monthly and yearly plans, highlighting the savings on the annual option.
    - Buttons for purchasing, restoring purchases, and closing the view.
    - A link to privacy policy and terms of service.

### 4.3. Feature Gating
- Implement checks throughout the app to determine if a feature should be enabled or show a "Pro" badge.
- **Example:**