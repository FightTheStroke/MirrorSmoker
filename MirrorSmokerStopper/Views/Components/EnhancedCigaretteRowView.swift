//
//  EnhancedCigaretteRowView.swift
//  MirrorSmokerStopper
//
//  Created by Claude on 03/09/25.
//

import SwiftUI
import SwiftData
import os.log

struct EnhancedCigaretteRowView: View {
    private static let logger = Logger(subsystem: "com.fightthestroke.MirrorSmokerStopper", category: "EnhancedCigaretteRowView")
    
    let cigarette: Cigarette
    let onDelete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingTagEditor = false
    @State private var showingDeleteConfirmation = false
    @State private var dragOffset: CGFloat = 0
    @State private var showingActions = false
    
    private let swipeThreshold: CGFloat = 60
    private let actionWidth: CGFloat = 140
    
    var body: some View {
        HStack(spacing: 0) {
            // Main cigarette row content
            cigaretteRowContent
                .offset(x: dragOffset)
                .liquidGlassBackground(backgroundColor: DS.Colors.glassPrimary)
                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
            
            // Action buttons (hidden behind)
            if showingActions {
                actionButtons
                    .frame(width: actionWidth)
                    .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
                    .transition(.move(edge: .trailing))
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation.width
                    
                    if translation < 0 {
                        // Dragging left - show actions
                        dragOffset = max(translation, -actionWidth)
                        
                        if abs(translation) > swipeThreshold && !showingActions {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showingActions = true
                            }
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    } else if showingActions {
                        // Dragging right while actions are showing
                        dragOffset = max(translation - actionWidth, -actionWidth)
                    }
                }
                .onEnded { value in
                    let translation = value.translation.width
                    let velocity = value.velocity.width
                    
                    withAnimation(.easeOut(duration: 0.3)) {
                        if showingActions {
                            if translation > swipeThreshold || velocity > 500 {
                                // Close actions
                                dragOffset = 0
                                showingActions = false
                            } else {
                                // Snap to open position
                                dragOffset = -actionWidth
                            }
                        } else {
                            if translation < -swipeThreshold || velocity < -500 {
                                // Open actions
                                dragOffset = -actionWidth
                                showingActions = true
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            } else {
                                // Snap back to closed
                                dragOffset = 0
                            }
                        }
                    }
                }
        )
        .clipped()
        .sheet(isPresented: $showingTagEditor) {
            TagEditingSheet(cigarette: cigarette)
        }
        .confirmationDialog(
            "delete.cigarette.confirmation".local(),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("delete".local(), role: .destructive) {
                withAnimation(.easeOut(duration: 0.3)) {
                    onDelete()
                }
            }
            Button("cancel".local(), role: .cancel) { }
        } message: {
            Text("delete.cigarette.confirmation.message".local())
        }
    }
    
    // MARK: - Main Content
    
    private var cigaretteRowContent: some View {
        HStack(spacing: DS.Space.md) {
            // Time and cigarette icon
            HStack(spacing: DS.Space.sm) {
                Image(systemName: "lungs.fill")
                    .foregroundColor(DS.Colors.cigarette)
                    .font(.system(size: DS.Size.iconSize))
                    .accessibilityHidden(true)
                
                Text(cigarette.timestamp, format: .dateTime.hour().minute())
                    .font(DS.Text.body)
                    .fontWeight(.medium)
                    .foregroundColor(DS.Colors.textPrimary)
            }
            
            Spacer()
            
            // Tags display
            tagsDisplay
        }
        .padding(.horizontal, DS.Space.lg)
        .padding(.vertical, DS.Space.md)
        .contentShape(Rectangle())
        .onTapGesture {
            if showingActions {
                withAnimation(.easeOut(duration: 0.3)) {
                    dragOffset = 0
                    showingActions = false
                }
            }
        }
    }
    
    // MARK: - Tags Display
    
    @ViewBuilder
    private var tagsDisplay: some View {
        if let tags = cigarette.tags, !tags.isEmpty {
            HStack(spacing: DS.Space.xs) {
                ForEach(tags.prefix(3), id: \.id) { tag in
                    tagChip(tag: tag)
                }
                
                if tags.count > 3 {
                    Text("plus.more.tags".local(with: tags.count - 3))
                        .font(DS.Text.caption2)
                        .padding(.horizontal, DS.Space.xs)
                        .padding(.vertical, 2)
                        .liquidGlassBackground(backgroundColor: DS.Colors.glassSecondary)
                        .foregroundColor(DS.Colors.textSecondary)
                        .cornerRadius(DS.Size.cardRadiusSmall)
                }
            }
        } else {
            // No tags indicator
            Text("no.tags".local())
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
        }
    }
    
    private func tagChip(tag: Tag) -> some View {
        Text(tag.name)
            .font(DS.Text.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, DS.Space.xs)
            .padding(.vertical, 2)
            .liquidGlassBackground(backgroundColor: tag.color.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(DS.Size.cardRadiusSmall)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 0) {
            // Edit tags button
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    dragOffset = 0
                    showingActions = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingTagEditor = true
                }
                
                Self.logger.info("Opening tag editor for cigarette")
            }) {
                VStack(spacing: DS.Space.xs) {
                    Image(systemName: "tag")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("tags".local())
                        .font(DS.Text.caption2)
                        .foregroundColor(.white)
                }
            }
            .frame(width: actionWidth / 2)
            .frame(maxHeight: .infinity)
            .liquidGlassBackground(backgroundColor: DS.Colors.primary)
            
            // Delete button
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    dragOffset = 0
                    showingActions = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showingDeleteConfirmation = true
                }
                
                Self.logger.info("Confirming cigarette deletion")
            }) {
                VStack(spacing: DS.Space.xs) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("delete".local())
                        .font(DS.Text.caption2)
                        .foregroundColor(.white)
                }
            }
            .frame(width: actionWidth / 2)
            .frame(maxHeight: .infinity)
            .liquidGlassBackground(backgroundColor: DS.Colors.danger)
        }
    }
}

// MARK: - Tag Editing Sheet

struct TagEditingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allTags: [Tag]
    
    let cigarette: Cigarette
    @State private var selectedTags: [Tag] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            TagSelectionInterface(
                selectedTags: $selectedTags,
                allTags: allTags
            )
            .navigationTitle("edit.tags".local())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".local()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveTags) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("save".local())
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
        .onAppear {
            selectedTags = cigarette.tags ?? []
        }
    }
    
    private func saveTags() {
        isLoading = true
        
        cigarette.tags = selectedTags.isEmpty ? nil : selectedTags
        
        do {
            try modelContext.save()
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            dismiss()
        } catch {
            // Handle error
            print("Error saving tags: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Tag Selection Interface

struct TagSelectionInterface: View {
    @Binding var selectedTags: [Tag]
    let allTags: [Tag]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DS.Space.sm) {
                ForEach(allTags) { tag in
                    tagRow(tag: tag)
                }
            }
            .padding(.horizontal, DS.Space.lg)
            .padding(.vertical, DS.Space.md)
        }
    }
    
    private func tagRow(tag: Tag) -> some View {
        let isSelected = selectedTags.contains(where: { $0.id == tag.id })
        
        return Button(action: {
            toggleTagSelection(tag)
        }) {
            HStack(spacing: DS.Space.md) {
                Circle()
                    .fill(tag.color)
                    .frame(width: 20, height: 20)
                
                Text(tag.name)
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.textSecondary)
            }
            .padding(.vertical, DS.Space.md)
            .padding(.horizontal, DS.Space.lg)
            .liquidGlassBackground(backgroundColor: isSelected ? DS.Colors.primary.opacity(0.1) : DS.Colors.glassPrimary)
            .cornerRadius(DS.Size.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.cardRadius)
                    .stroke(
                        isSelected ? DS.Colors.primary.opacity(0.5) : DS.Colors.glassQuaternary,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleTagSelection(_ tag: Tag) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if let index = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
    }
}

#Preview {
    EnhancedCigaretteRowView(
        cigarette: Cigarette(timestamp: Date(), note: "Test"),
        onDelete: {}
    )
    .modelContainer(for: [Cigarette.self, Tag.self], inMemory: true)
    .padding()
}