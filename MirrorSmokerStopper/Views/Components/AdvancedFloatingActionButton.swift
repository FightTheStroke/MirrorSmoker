//
//  AdvancedFloatingActionButton.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI

struct AdvancedFloatingActionButton: View {
    let quickAction: () -> Void
    let longPressAction: () -> Void
    let logPurchaseAction: (() -> Void)? // Add this parameter
    
    @State private var showingMenu = false
    
    init(
        quickAction: @escaping () -> Void,
        longPressAction: @escaping () -> Void,
        logPurchaseAction: (() -> Void)? = nil // Add this parameter
    ) {
        self.quickAction = quickAction
        self.longPressAction = longPressAction
        self.logPurchaseAction = logPurchaseAction
    }
    
    var body: some View {
        VStack {
            if showingMenu {
                // Log Purchase Button
                if logPurchaseAction != nil {
                    Button(action: {
                        showingMenu = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            logPurchaseAction?()
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                            Text("Log Purchase")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(width: 80)
                        .padding(.vertical, 8)
                        .background(DS.Colors.glassSecondary)
                        .foregroundColor(DS.Colors.textPrimary)
                        .cornerRadius(12)
                    }
                    .transition(.scale)
                }
                
                // Tagged Cigarette Button
                Button(action: {
                    showingMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        longPressAction()
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "tag.circle.fill")
                            .font(.title2)
                        Text("Tagged")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(width: 80)
                    .padding(.vertical, 8)
                    .background(DS.Colors.glassSecondary)
                    .foregroundColor(DS.Colors.textPrimary)
                    .cornerRadius(12)
                }
                .transition(.scale)
            }
            
            // Main FAB
            Button(action: {
                if showingMenu {
                    showingMenu = false
                } else {
                    quickAction()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.primary)
                        .frame(width: DS.Size.fabSize, height: DS.Size.fabSize)
                        .shadow(color: DS.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    if showingMenu {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .onLongPressGesture(minimumDuration: 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showingMenu = true
                }
            }
        }
        .onTapGesture {
            // Dismiss menu when tapping outside
        }
    }
}