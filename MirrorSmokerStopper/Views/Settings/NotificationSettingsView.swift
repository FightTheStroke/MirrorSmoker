//
//  NotificationSettingsView.swift
//  MirrorSmokerStopper
//
//  Settings for AI Coach notifications
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @StateObject private var jitaiPlanner = JITAIPlanner.shared
    @StateObject private var aiConfig = AIConfiguration.shared
    
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Form {
            // Permission Status
            Section {
                HStack {
                    Label(NSLocalizedString("notifications.permission.label", comment: "Notification Permission"), systemImage: "bell.badge")
                    Spacer()
                    statusBadge
                }
                
                if notificationStatus != .authorized {
                    Button(action: requestPermission) {
                        Text(NSLocalizedString("notifications.enable.button", comment: "Enable Notifications"))
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text(NSLocalizedString("notifications.permissions.header", comment: "PERMISSIONS"))
            }
            
            // AI Coach Settings
            Section {
                Toggle(isOn: $jitaiPlanner.isEnabled) {
                    Label(NSLocalizedString("notifications.ai.coach.toggle", comment: "AI Coach Notifications"), systemImage: "brain.head.profile")
                }
                .disabled(notificationStatus != .authorized)
                
                if jitaiPlanner.isEnabled {
                    Stepper(value: $jitaiPlanner.maxNotificationsPerDay, in: 1...10) {
                        HStack {
                            Text(NSLocalizedString("notifications.daily.limit", comment: "Daily Limit"))
                            Spacer()
                            Text("\(jitaiPlanner.maxNotificationsPerDay)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Quiet Hours
                    Toggle(isOn: .constant(true)) {
                        Label(NSLocalizedString("notifications.quiet.hours", comment: "Quiet Hours"), systemImage: "moon.fill")
                    }
                    
                    if true { // Always show for now
                        HStack {
                            Text(NSLocalizedString("notifications.quiet.from", comment: "From"))
                            Spacer()
                            Text("\(jitaiPlanner.quietHoursStart):00")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(NSLocalizedString("notifications.quiet.to", comment: "To"))
                            Spacer()
                            Text("\(jitaiPlanner.quietHoursEnd):00")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } header: {
                Text(NSLocalizedString("notifications.ai.coach.header", comment: "AI COACH"))
            } footer: {
                Text(NSLocalizedString("notifications.ai.coach.footer", comment: "AI Coach will send smart notifications when you're most vulnerable to cravings"))
            }
            
            // Notification Types
            Section {
                NotificationTypeRow(
                    title: NSLocalizedString("notifications.type.motivational.title", comment: "Motivational Tips"),
                    subtitle: NSLocalizedString("notifications.type.motivational.subtitle", comment: "Personalized encouragement"),
                    icon: "heart.fill",
                    color: .pink,
                    isEnabled: .constant(true)
                )
                
                NotificationTypeRow(
                    title: NSLocalizedString("notifications.type.risk.title", comment: "Risk Alerts"),
                    subtitle: NSLocalizedString("notifications.type.risk.subtitle", comment: "High-risk time warnings"),
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    isEnabled: .constant(true)
                )
                
                NotificationTypeRow(
                    title: NSLocalizedString("notifications.type.breathing.title", comment: "Breathing Reminders"),
                    subtitle: NSLocalizedString("notifications.type.breathing.subtitle", comment: "Stress management exercises"),
                    icon: "wind",
                    color: .blue,
                    isEnabled: .constant(true)
                )
                
                NotificationTypeRow(
                    title: NSLocalizedString("notifications.type.progress.title", comment: "Progress Updates"),
                    subtitle: NSLocalizedString("notifications.type.progress.subtitle", comment: "Celebrate your achievements"),
                    icon: "star.fill",
                    color: .yellow,
                    isEnabled: .constant(true)
                )
            } header: {
                Text(NSLocalizedString("notifications.types.header", comment: "NOTIFICATION TYPES"))
            }
            
            // Test Section
            Section {
                Button(action: sendTestNotification) {
                    Label(NSLocalizedString("notifications.test.button", comment: "Send Test Notification"), systemImage: "bell.and.waves.left.and.right")
                        .foregroundColor(.blue)
                }
            } footer: {
                Text(NSLocalizedString("notifications.test.footer", comment: "Test that notifications are working correctly"))
            }
        }
        .navigationTitle(NSLocalizedString("notifications.title", comment: "Notifications"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkNotificationStatus()
        }
        .alert(NSLocalizedString("notifications.alert.title", comment: "Enable Notifications"), isPresented: $showingPermissionAlert) {
            Button(NSLocalizedString("notifications.alert.settings", comment: "Settings"), action: openSettings)
            Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("notifications.alert.message", comment: "Please enable notifications in Settings to receive AI Coach guidance"))
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        switch notificationStatus {
        case .authorized:
            Text(NSLocalizedString("notifications.status.enabled", comment: "Enabled"))
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .foregroundColor(.green)
                .cornerRadius(4)
        case .denied:
            Text(NSLocalizedString("notifications.status.disabled", comment: "Disabled"))
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(4)
        default:
            Text(NSLocalizedString("notifications.status.notset", comment: "Not Set"))
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.gray)
                .cornerRadius(4)
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    notificationStatus = .authorized
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendTestNotification() {
        Task {
            await JITAIPlanner.shared.evaluateAndNotify()
        }
    }
}

struct NotificationTypeRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
}