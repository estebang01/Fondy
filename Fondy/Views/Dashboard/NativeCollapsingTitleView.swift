//
//  NativeCollapsingTitleView.swift
//  Fondy
//
//  Demonstrates native iOS Settings-style collapsing large title behavior.
//  Uses standard NavigationStack APIs with no custom hacks.
//

import SwiftUI

/// A view that replicates the exact native iOS Settings collapsing large title behavior.
///
/// This implementation uses only native SwiftUI navigation APIs:
/// - NavigationStack for the navigation container
/// - .navigationTitle() for the title
/// - .navigationBarTitleDisplayMode(.large) for large title mode
/// - List with .insetGrouped style for Settings-like appearance
///
/// The collapsing behavior is handled entirely by the system with zero custom code.
struct NativeCollapsingTitleView: View {
    var body: some View {
        NavigationStack {
            List {
                // Section 1: Profile
                Section {
                    profileRow
                } header: {
                    Text("Account")
                }
                
                // Section 2: General Settings
                Section {
                    settingsRow(icon: "bell.fill", color: .red, title: "Notifications", subtitle: "Enabled")
                    settingsRow(icon: "lock.fill", color: .blue, title: "Privacy & Security", subtitle: nil)
                    settingsRow(icon: "paintbrush.fill", color: .purple, title: "Appearance", subtitle: "Automatic")
                    settingsRow(icon: "globe", color: .cyan, title: "Language & Region", subtitle: "English")
                } header: {
                    Text("Preferences")
                }
                
                // Section 3: App Settings
                Section {
                    settingsRow(icon: "chart.bar.fill", color: .green, title: "Data & Analytics", subtitle: nil)
                    settingsRow(icon: "icloud.fill", color: .blue, title: "iCloud Sync", subtitle: "On")
                    settingsRow(icon: "arrow.down.circle.fill", color: .orange, title: "Storage", subtitle: "2.4 GB available")
                } header: {
                    Text("App")
                }
                
                // Section 4: Support
                Section {
                    settingsRow(icon: "questionmark.circle.fill", color: .yellow, title: "Help & Support", subtitle: nil)
                    settingsRow(icon: "star.fill", color: .pink, title: "Rate Fondy", subtitle: nil)
                    settingsRow(icon: "envelope.fill", color: .indigo, title: "Contact Us", subtitle: nil)
                } header: {
                    Text("Support")
                }
                
                // Section 5: Legal
                Section {
                    settingsRow(icon: "doc.text.fill", color: .gray, title: "Terms of Service", subtitle: nil)
                    settingsRow(icon: "hand.raised.fill", color: .gray, title: "Privacy Policy", subtitle: nil)
                    settingsRow(icon: "info.circle.fill", color: .gray, title: "Licenses", subtitle: nil)
                } header: {
                    Text("Legal")
                }
                
                // Section 6: App Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("1.0.0 (42)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("2026.03.01")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                } footer: {
                    VStack(spacing: 8) {
                        Text("Made with ❤️ for iOS")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Text("© 2026 Fondy Inc. All rights reserved.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Profile Row
    
    private var profileRow: some View {
        HStack(spacing: 16) {
            // Profile picture
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("John Appleseed")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                
                Text("john@example.com")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Apple ID, iCloud, Media & Purchases")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Settings Row
    
    private func settingsRow(
        icon: String,
        color: Color,
        title: String,
        subtitle: String?
    ) -> some View {
        HStack(spacing: 12) {
            // Icon with colored background
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
            
            // Title
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer(minLength: 0)
            
            // Subtitle (if provided)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    NativeCollapsingTitleView()
}

#Preview("In Navigation Context") {
    NavigationStack {
        List {
            NavigationLink("Open Settings") {
                NativeCollapsingTitleView()
            }
        }
        .navigationTitle("Demo")
    }
}
