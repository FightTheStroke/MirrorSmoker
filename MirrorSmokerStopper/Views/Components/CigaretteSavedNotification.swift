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
    
    var body: some View {
        HStack(spacing: DS.Space.md) {
            // Success icon
            ZStack {
                Circle()
                    .fill(DS.Colors.success)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
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
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                showNotification()
            } else {
                hideNotification()
            }
        }
    }
    
    private func showNotification() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            offset = 0
            opacity = 1
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