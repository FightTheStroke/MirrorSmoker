//
//  CigaretteSavedNotification.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI

struct CigaretteSavedNotification: View {
    let tagCount: Int
    @Binding var isShowing: Bool
    
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var iconScale: CGFloat = 0.5
    
    var body: some View {
        HStack(spacing: DS.Space.md) {
            // Success icon with enhanced animation
            ZStack {
                Circle()
                    .fill(DS.Colors.success)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(DS.Colors.success.opacity(0.3), lineWidth: 2)
                            .scaleEffect(iconScale > 0.9 ? 1.2 : 1.0)
                            .opacity(iconScale > 0.9 ? 0.5 : 0)
                    )
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(iconScale)
            }
            
            // Message
            VStack(alignment: .leading, spacing: 2) {
                Text("cigarette.saved.title".local())
                    .font(DS.Text.body)
                    .fontWeight(.semibold)
                    .foregroundColor(DS.Colors.textPrimary)
                
                if tagCount > 0 {
                    Text("cigarette.saved.with.tags".local(with: tagCount))
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                } else {
                    Text("cigarette.saved.message".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Close button
            Button(action: {
                dismissNotification()
            }) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(DS.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, DS.Space.md)
        .background(
            RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                .fill(.regularMaterial)
                .shadow(
                    color: DS.Colors.success.opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .offset(y: offset)
        .opacity(opacity)
        .scaleEffect(scale)
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                showNotification()
            } else {
                hideNotification()
            }
        }
    }
    
    private func showNotification() {
        // Staggered animations for more polish
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            offset = 0
            opacity = 1
            scale = 1.0
        }
        
        // Delayed icon animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
            iconScale = 1.0
        }
        
        // Bounce effect after delay
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4).delay(0.3)) {
            iconScale = 1.1
        }
        
        // Return to normal
        withAnimation(.spring(response: 0.2, dampingFraction: 0.8).delay(0.5)) {
            iconScale = 1.0
        }
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if isShowing {
                dismissNotification()
            }
        }
    }
    
    private func hideNotification() {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = -100
            opacity = 0
            scale = 0.8
            iconScale = 0.5
        }
    }
    
    private func dismissNotification() {
        isShowing = false
    }
}

// MARK: - Notification Overlay Modifier

struct CigaretteSavedNotificationModifier: ViewModifier {
    @Binding var isShowing: Bool
    let tagCount: Int
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    if isShowing {
                        CigaretteSavedNotification(
                            tagCount: tagCount,
                            isShowing: $isShowing
                        )
                        .padding(.horizontal, DS.Space.lg)
                        .padding(.top, DS.Space.lg)
                    }
                    
                    Spacer()
                }
                .allowsHitTesting(isShowing)
                , alignment: .top
            )
    }
}

extension View {
    func cigaretteSavedNotification(isShowing: Binding<Bool>, tagCount: Int = 0) -> some View {
        self.modifier(CigaretteSavedNotificationModifier(isShowing: isShowing, tagCount: tagCount))
    }
}

#Preview {
    VStack {
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DS.Colors.background)
    .cigaretteSavedNotification(isShowing: .constant(true), tagCount: 2)
}
