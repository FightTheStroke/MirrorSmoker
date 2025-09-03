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

    // Parametri ottimizzati per gesture
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
                    title: "fab.log.purchase".local(),
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
                title: "fab.tagged".local(),
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
        Button(action: {
            if showingMenu {
                dismissMenu()
            } else {
                executeQuickAction()
            }
        }) {
            ZStack {
                // FAB Visuale (56px)
                Circle()
                    .fill(DS.Colors.primary)
                    .frame(width: visualButtonSize, height: visualButtonSize)
                    .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(isDetectingLongPress ? 1.15 : 1.0)

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
            .frame(width: gestureAreaSize, height: gestureAreaSize)
            .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.6)
                .onChanged { _ in
                    if !isDetectingLongPress {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isDetectingLongPress = true
                        }
                    }
                }
                .onEnded { _ in
                    if !showingMenu {
                        triggerMenuOpen()
                    }
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isDetectingLongPress = false
                    }
                }
        )
    }

    // MARK: - Action Handlers

    private func triggerMenuOpen() {
        withAnimation(DS.Animation.spring) {
            showingMenu = true
        }
        // Haptic feedback quando menu si apre
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func dismissMenu(withDelay delay: Bool = false, completion: (() -> Void)? = nil) {
        let actualCompletion = {
            withAnimation(DS.Animation.spring) {
                showingMenu = false
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
