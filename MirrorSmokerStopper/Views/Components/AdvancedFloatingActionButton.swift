//
//  EnhancedFloatingActionButton.swift
//  MirrorSmokerStopper - Version Migliorata con Design System
//
//  Miglioramenti:
//  - Area gesture più grande (80px) per touch target migliore
//  - DragGesture invece di simultaneous gestures per meno conflitti
//  - Feedback visivo immediato durante press/hold
//  - Durata long press ottimizzata (0.6s) per UX migliore
//  - Scale animation più fluide
//  - Supporto Design Sizes adattivi
//

import SwiftUI

struct AdvancedFloatingActionButton: View {
    let quickAction: () -> Void
    let longPressAction: () -> Void
    let logPurchaseAction: (() -> Void)?

    // Stati per gesture migliorata
    @State private var showingMenu = false
    @State private var isDetectingLongPress = false
    @State private var dragOffset: CGFloat = 0

    // Parametri ottimizzati per gesture
    private let swipeThreshold: CGFloat = 60
    private let longPressDuration: CGFloat = 0.6  // Più responsive di 0.3s precedente
    private let gestureAreaSize: CGFloat = 80    // Area più grande di 56px precedente
    private let visualButtonSize: CGFloat = 56   // Dimensioni FAB visuale

    init(
        quickAction: @escaping () -> Void,
        longPressAction: @escaping () -> Void,
        logPurchaseAction: (() -> Void)? = nil
    ) {
        self.quickAction = quickAction
        self.longPressAction = longPressAction
        self.logPurchaseAction = logPurchaseAction
    }

    var body: some View {
        ZStack {
            // Menu overlay piò ampio per dismiss
            if showingMenu {
                Color.black.opacity(0.1)
                    .onTapGesture { dismissMenu() }
            }

            VStack {
                // Menu espandibile con opzioni
                if showingMenu {
                    menuOptions
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Main FAB con gesture migliorata
                HStack {
                    Spacer()
                    mainFAB
                }
            }
        }
        .frame(width: gestureAreaSize, height: gestureAreaSize)
        .padding(DS.AdaptiveSpace.lg)
    }

    // MARK: - Menu Options
    private var menuOptions: some View {
        VStack(spacing: DS.AdaptiveSpace.sm) {
            // Log Purchase Button
            if logPurchaseAction != nil {
                actionButton(
                    icon: "dollarsign.circle.fill",
                    title: "Log Purchase",
                    action: {
                        dismissMenu(withDelay: true) {
                            logPurchaseAction?()
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }

            // Tagged Cigarette Button
            actionButton(
                icon: "tag.circle.fill",
                title: "Tagged",
                action: {
                    dismissMenu(withDelay: true) {
                        longPressAction()
                    }
                }
            )
            .transition(.scale.combined(with: .opacity))
        }
        .offset(y: -DS.AdaptiveSpace.sm)
    }

    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(DS.Colors.primary)
                Text(title)
                    .font(DS.Text.caption)
                    .fontWeight(.medium)
                    .foregroundColor(DS.Colors.textPrimary)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
            .cornerRadius(DS.Size.cardRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Main FAB
    private var mainFAB: some View {
        ZStack {
            // Area invisibile per gesture più ampia (80px)
            Circle()
                .fill(Color.clear)
                .frame(width: gestureAreaSize, height: gestureAreaSize)
                .contentShape(Circle())
                // === GESTURE MIGLIORATA ===
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(value.translation)
                        }
                        .onEnded { value in
                            handleDragEnded(value.translation)
                        }
                )

            // FAB Visuale (56px)
            ZStack {
                Circle()
                    .fill(DS.Colors.primary)
                    .frame(width: visualButtonSize, height: visualButtonSize)
                    .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(isDetectingLongPress ? 1.15 : 1.0)  // Feedback visivo immediato

                if showingMenu {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isDetectingLongPress ? -90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isDetectingLongPress)
                } else {
                    ZStack {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isDetectingLongPress ? 45 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isDetectingLongPress)

                        // Pulse animation quando idle (solo se non ci sono problemi di accessibility)
                        if !isDetectingLongPress && !showingMenu {
                            Circle()
                                .stroke(DS.Colors.primary.opacity(0.3), lineWidth: 2)
                                .frame(width: visualButtonSize + 4, height: visualButtonSize + 4)
                                .scaleEffect(isDetectingLongPress ? 1.1 : 1.0)
                                .opacity(isDetectingLongPress ? 0 : 0.5)
                                .animation(
                                    UIAccessibility.isReduceMotionEnabled ?
                                        .linear(duration: 0.1) :
                                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: isDetectingLongPress
                                )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Enhanced Gesture Handling

    @State private var longPressTimer: Timer?

    private func handleDragChanged(_ translation: CGSize) {
        if !isDetectingLongPress {
            // Inizia detection long press
            isDetectingLongPress = true

            // Timer per long press più responsive (0.6s)
            longPressTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { [self] _ in
                if isDetectingLongPress {
                    triggerMenuOpen()
                }
            }
        }
    }

    private func handleDragEnded(_ translation: CGSize) {
        defer { resetGestureState() }

        if showingMenu {
            // Menu già aperto - gestisci secondo logica
            if translation.height < -swipeThreshold {
                dismissMenu()
            } else {
                // Snap back to menu position
                withAnimation(DS.Animation.spring) {
                    dragOffset = 0  // Reset offset per menu aperto
                }
            }
        } else {
            // Menu chiuso - gestisci secondo logica
            if abs(translation.height) < swipeThreshold && abs(translation.width) < swipeThreshold {
                // Touch breve - quick action
                executeQuickAction()
            }
            // Altrimenti snap back senza fare nulla
        }
    }

    private func triggerMenuOpen() {
        withAnimation(DS.Animation.spring) {
            showingMenu = true
            dragOffset = 0
        }
        // Haptic feedback quando menu si apre
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func dismissMenu(withDelay delay: Bool = false, completion: (() -> Void)? = nil) {
        let actualCompletion = {
            withAnimation(DS.Animation.spring) {
                showingMenu = false
                dragOffset = 0
            }
            completion?()
        }

        if delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: actualCompletion)
        } else {
            actualCompletion()
        }
    }

    private func executeQuickAction() {
        quickAction()
        // Haptic feedback per quick action
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func resetGestureState() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        isDetectingLongPress = false

        withAnimation(.easeInOut(duration: 0.2)) {
            dragOffset = 0
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.white
        AdvancedFloatingActionButton(
            quickAction: { /* Quick action */ },
            longPressAction: { /* Long press action */ },
            logPurchaseAction: { /* Log purchase */ }
        )
    }
}
