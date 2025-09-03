//
//  AdvancedFloatingActionButton.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI
import os.log

struct AdvancedFloatingActionButton: View {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "AdvancedFAB")
    
    let quickAction: () -> Void
    let longPressAction: () -> Void
    
    @State private var isPressed = false
    @State private var rotationAngle: Double = 0
    @State private var isLongPressing = false
    @State private var longPressTimer: Timer?
    @State private var showRippleEffect = false
    
    private let longPressDuration: Double = 0.6
    
    var body: some View {
        ZStack {
            // Ripple effect for long press
            if showRippleEffect {
                Circle()
                    .stroke(DS.Colors.primary, lineWidth: 2)
                    .scaleEffect(isLongPressing ? 1.3 : 1.0)
                    .opacity(isLongPressing ? 0.0 : 0.7)
                    .frame(width: 56, height: 56)
                    .animation(.easeOut(duration: longPressDuration), value: isLongPressing)
            }
            
            Button(action: {}) {
                ZStack {
                    // Background gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isPressed ? 
                                    [DS.Colors.danger.opacity(0.8), DS.Colors.danger] : 
                                    [DS.Colors.danger, DS.Colors.danger.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    // Icon with animation
                    Image(systemName: isLongPressing ? "tag.fill" : "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                        .animation(.easeInOut(duration: 0.3), value: isLongPressing)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .shadow(
                color: DS.Colors.danger.opacity(isPressed ? 0.3 : 0.4),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressed = true
                            }
                            startLongPressTimer()
                        }
                    }
                    .onEnded { _ in
                        stopLongPressTimer()
                        
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                        
                        if isLongPressing {
                            // Long press completed - show tag selection
                            triggerLongPressAction()
                        } else {
                            // Quick tap - add cigarette immediately
                            triggerQuickAction()
                        }
                        
                        resetLongPressState()
                    }
            )
            .accessibilityLabel("fab.add.cigarette".local())
            .accessibilityHint("fab.add.cigarette.hint".local())
        }
    }
    
    private func startLongPressTimer() {
        longPressTimer?.invalidate()
        
        // Show ripple effect
        showRippleEffect = true
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: longPressDuration, repeats: false) { _ in
            if isPressed {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLongPressing = true
                    rotationAngle += 45
                }
                
                // Strong haptic feedback for long press
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                
                Self.logger.info("Long press detected - will show tag selection")
            }
        }
    }
    
    private func stopLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    private func triggerQuickAction() {
        // Light haptic feedback for quick tap
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            rotationAngle += 90
        }
        
        Self.logger.info("Quick tap - adding cigarette without tags")
        
        // Small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            quickAction()
        }
    }
    
    private func triggerLongPressAction() {
        Self.logger.info("Long press completed - opening tag selection")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            longPressAction()
        }
    }
    
    private func resetLongPressState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isLongPressing = false
                showRippleEffect = false
            }
        }
    }
}

#Preview {
    AdvancedFloatingActionButton(
        quickAction: {
            print("Quick action")
        },
        longPressAction: {
            print("Long press action")
        }
    )
    .padding(50)
}