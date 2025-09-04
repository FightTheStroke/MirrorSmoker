//
//  MyWhyEditor.swift
//  MirrorSmokerStopper
//
//  Created by Assistant on 03/09/25.
//

import SwiftUI

// MARK: - My Why Editor
struct MyWhyEditor: View {
    @State private var motivationText: String = ""
    @State private var isEditing = false
    @State private var showCoachingOptions = false
    @State private var selectedMotivationTemplate: MotivationTemplate?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.md) {
            HStack {
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    HStack(spacing: DS.AdaptiveSpace.xs) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(DS.Colors.primary)
                            .font(.title2)
                        Text("motivation.my.why".local())
                            .font(DS.Text.title)
                            .foregroundColor(DS.Colors.primary)
                    }
                    Text("motivation.description".local())
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                }
                
                Spacer()
                
                Button(action: { 
                    withAnimation(.spring()) {
                        isEditing.toggle()
                        if isEditing && motivationText.isEmpty {
                            showCoachingOptions = true
                        }
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(DS.Colors.primary)
                }
            }
            
            if isEditing {
                VStack(spacing: DS.AdaptiveSpace.md) {
                    // Coaching templates
                    if showCoachingOptions {
                        MotivationTemplatesSection(
                            selectedTemplate: $selectedMotivationTemplate,
                            onTemplateSelected: { template in
                                motivationText = template.text
                                withAnimation(.easeInOut) {
                                    showCoachingOptions = false
                                }
                            }
                        )
                    }
                    
                    // Text editor
                    ZStack(alignment: .topLeading) {
                        if motivationText.isEmpty {
                            Text("motivation.placeholder".local())
                                .font(DS.Text.body)
                                .foregroundColor(DS.Colors.textTertiary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                        }
                        
                        TextEditor(text: $motivationText)
                            .font(DS.Text.body)
                            .foregroundColor(DS.Colors.textPrimary)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                    .padding(DS.AdaptiveSpace.sm)
                    .background(DS.Colors.glassPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
                    
                    // Action buttons
                    HStack {
                        if !showCoachingOptions && motivationText.isEmpty {
                            Button("motivation.show.templates".local()) {
                                withAnimation(.spring()) {
                                    showCoachingOptions = true
                                }
                            }
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.primary)
                        }
                        
                        Spacer()
                        
                        if !motivationText.isEmpty {
                            Button("motivation.clear".local()) {
                                withAnimation(.easeInOut) {
                                    motivationText = ""
                                    showCoachingOptions = true
                                }
                            }
                            .font(DS.Text.caption)
                            .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                }
                .transition(.opacity.combined(with: .slide))
            } else {
                // Display mode
                if !motivationText.isEmpty {
                    Text(motivationText)
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                        .padding(DS.AdaptiveSpace.md)
                        .background(DS.Colors.glassPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
                } else {
                    EmptyMotivationView()
                }
            }
        }
        .padding(DS.AdaptiveSpace.lg)
        .liquidGlassCard(elevation: DS.Shadow.medium)
    }
}

// MARK: - Motivation Templates Section
struct MotivationTemplatesSection: View {
    @Binding var selectedTemplate: MotivationTemplate?
    let onTemplateSelected: (MotivationTemplate) -> Void
    
    private let templates = MotivationTemplate.allTemplates
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.AdaptiveSpace.sm) {
            Text("motivation.templates.title".local())
                .font(DS.Text.headline)
                .foregroundColor(DS.Colors.textPrimary)
            
            Text("motivation.templates.subtitle".local())
                .font(DS.Text.caption)
                .foregroundColor(DS.Colors.textSecondary)
            
            LazyVStack(spacing: DS.AdaptiveSpace.xs) {
                ForEach(templates) { template in
                    MotivationTemplateCard(
                        template: template,
                        isSelected: selectedTemplate?.id == template.id
                    ) {
                        selectedTemplate = template
                        onTemplateSelected(template)
                    }
                }
            }
        }
        .padding(DS.AdaptiveSpace.md)
        .background(DS.Colors.glassSecondary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
    }
}

// MARK: - Motivation Template Card
struct MotivationTemplateCard: View {
    let template: MotivationTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DS.AdaptiveSpace.sm) {
                Text(template.emoji)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: DS.AdaptiveSpace.xs) {
                    Text(template.title)
                        .font(DS.Text.body)
                        .foregroundColor(DS.Colors.textPrimary)
                    
                    Text(template.preview)
                        .font(DS.Text.caption)
                        .foregroundColor(DS.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DS.Colors.primary)
                }
            }
            .padding(DS.AdaptiveSpace.sm)
            .background(isSelected ? DS.Colors.primary.opacity(0.1) : DS.Colors.glassTertiary)
            .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.buttonRadiusSmall))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty Motivation View
struct EmptyMotivationView: View {
    var body: some View {
        VStack(spacing: DS.AdaptiveSpace.md) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 32))
                .foregroundColor(DS.Colors.textTertiary)
            
            VStack(spacing: DS.AdaptiveSpace.xs) {
                Text("motivation.empty.title".local())
                    .font(DS.Text.headline)
                    .foregroundColor(DS.Colors.textPrimary)
                
                Text("motivation.empty.subtitle".local())
                    .font(DS.Text.body)
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(DS.Colors.glassPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.AdaptiveSize.cardRadiusSmall))
    }
}

// MARK: - Motivation Template Model
struct MotivationTemplate: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let text: String
    let preview: String
    
    static let allTemplates: [MotivationTemplate] = [
        MotivationTemplate(
            title: "motivation.template.family.title".local(),
            emoji: "👨‍👩‍👧‍👦",
            text: "motivation.template.family.text".local(),
            preview: "motivation.template.family.preview".local()
        ),
        MotivationTemplate(
            title: "motivation.template.health.title".local(),
            emoji: "❤️",
            text: "motivation.template.health.text".local(),
            preview: "motivation.template.health.preview".local()
        ),
        MotivationTemplate(
            title: "motivation.template.money.title".local(),
            emoji: "💰",
            text: "motivation.template.money.text".local(),
            preview: "motivation.template.money.preview".local()
        ),
        MotivationTemplate(
            title: "motivation.template.freedom.title".local(),
            emoji: "🕊️",
            text: "motivation.template.freedom.text".local(),
            preview: "motivation.template.freedom.preview".local()
        ),
        MotivationTemplate(
            title: "motivation.template.future.title".local(),
            emoji: "🌟",
            text: "motivation.template.future.text".local(),
            preview: "motivation.template.future.preview".local()
        )
    ]
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DS.AdaptiveSpace.xl) {
            MyWhyEditor()
        }
        .padding()
    }
    .background(DS.Colors.backgroundSecondary)
}