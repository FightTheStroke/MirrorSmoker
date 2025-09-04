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
    @State private var menuTimer: Timer?

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
        VStack(spacing: 16) {
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
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .move(edge: .bottom)),
                    removal: .scale.combined(with: .opacity)
                ))
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
            .transition(.asymmetric(
                insertion: .scale.combined(with: .move(edge: .bottom)),
                removal: .scale.combined(with: .opacity)
            ))
        }
        .offset(y: -20)
        .background(
            // Subtle backdrop for better visibility
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Reset button state when app becomes active
            if showingMenu {
                dismissMenu()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            // Reset button state when app goes to background
            if showingMenu {
                dismissMenu()
            }
        }
    }

    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(DS.Colors.primary)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 120, height: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DS.Colors.backgroundSecondary)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
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
                    // Don't start long press detection if menu is already showing
                    if !isDetectingLongPress && !showingMenu {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isDetectingLongPress = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isDetectingLongPress = false
                    }
                    
                    if !showingMenu {
                        triggerMenuOpen()
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
        
        // Auto-dismiss menu after 8 seconds for safety
        menuTimer?.invalidate()
        menuTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { _ in
            dismissMenu()
        }
    }

    private func dismissMenu(withDelay delay: Bool = false, completion: (() -> Void)? = nil) {
        let actualCompletion = {
            withAnimation(DS.Animation.spring) {
                showingMenu = false
                isDetectingLongPress = false // Ensure long press state is reset
            }
            menuTimer?.invalidate()
            menuTimer = nil
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
