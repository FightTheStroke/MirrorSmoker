//
//  FloatingActionButton.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        Button(action: {
            // Smooth haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Trigger rotation animation
            withAnimation(.easeInOut(duration: 0.3)) {
                rotationAngle += 90
            }
            
            // Call action with slight delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
            }
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: isPressed ? [Color.red.opacity(0.8), Color.red] : [Color.red, Color.red.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .rotationEffect(.degrees(rotationAngle))
                .shadow(
                    color: Color.red.opacity(isPressed ? 0.3 : 0.4),
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel(NSLocalizedString("fab.add.cigarette", comment: ""))
        .accessibilityHint(NSLocalizedString("fab.add.cigarette.hint", comment: ""))
    }
}

#Preview {
    FloatingActionButton(action: {})
}