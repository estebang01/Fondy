//
//  ListRowPressInteraction.swift
//  Fondy
//
//  Native iOS List row micro-interaction with sustained long press effect.
//  Transforms standard full-width rows into card-style with rounded corners.
//

import SwiftUI

// MARK: - View Modifier

/// Adds a native iOS-style long press interaction to List rows.
///
/// Transforms the row from full-width to a rounded card on sustained press.
/// - Normal: Full width, no radius, no shadow
/// - Pressed: Inset padding, rounded corners, subtle shadow, scale down
/// - Stays rounded until finger leaves the touch area
struct ListRowPressInteraction: ViewModifier {
    @State private var isPressed = false
    @State private var isActivated = false
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, isActivated ? 14 : 0)
            .background(
                RoundedRectangle(
                    cornerRadius: isActivated ? 20 : 0,
                    style: .continuous
                )
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(isActivated ? 0.08 : 0),
                    radius: isActivated ? 12 : 0,
                    y: isActivated ? 4 : 0
                )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.85),
                value: isPressed
            )
            .animation(
                .spring(response: 0.35, dampingFraction: 0.85),
                value: isActivated
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.35)
                    .onChanged { _ in
                        if !isActivated {
                            Haptics.light()
                            isActivated = true
                        }
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        // isActivated se mantiene true
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        // Solo cuando el dedo sale completamente
                        isActivated = false
                        isPressed = false
                    }
            )
    }
}

extension View {
    /// Applies native iOS List row long press interaction.
    ///
    /// Example:
    /// ```swift
    /// List {
    ///     ForEach(items) { item in
    ///         NavigationLink(value: item) {
    ///             MyRowContent(item: item)
    ///         }
    ///         .listRowPressInteraction()
    ///     }
    /// }
    /// ```
    func listRowPressInteraction() -> some View {
        modifier(ListRowPressInteraction())
    }
}

// MARK: - Standalone Row Component

/// A complete List row component with built-in press interaction.
///
/// Use this for custom rows that need the native press behavior.
struct InteractiveListRow<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    @State private var isActivated = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, isActivated ? 14 : 0)
            .background(
                RoundedRectangle(
                    cornerRadius: isActivated ? 20 : 0,
                    style: .continuous
                )
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(isActivated ? 0.08 : 0),
                    radius: isActivated ? 12 : 0,
                    y: isActivated ? 4 : 0
                )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.35, dampingFraction: 0.85),
                value: isPressed
            )
            .animation(
                .spring(response: 0.35, dampingFraction: 0.85),
                value: isActivated
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.35)
                    .onChanged { _ in
                        if !isActivated {
                            Haptics.light()
                            isActivated = true
                        }
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        // isActivated se mantiene true
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        // Solo cuando el dedo sale completamente
                        isActivated = false
                        isPressed = false
                    }
            )
    }
}

// MARK: - Usage Examples

#Preview("List with Interactive Rows") {
    NavigationStack {
        List {
            Section("With Modifier") {
                ForEach(0..<5) { index in
                    NavigationLink {
                        Text("Detail \(index)")
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Item \(index)")
                                    .font(.body)
                                Text("Subtitle text")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("$\(index * 10)")
                                .font(.body.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowPressInteraction()
                }
            }
            
            Section("With Component") {
                ForEach(5..<10) { index in
                    InteractiveListRow {
                        NavigationLink {
                            Text("Detail \(index)")
                        } label: {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Item \(index)")
                                        .font(.body)
                                    Text("Subtitle text")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("$\(index * 10)")
                                    .font(.body.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            Section("Standard iOS Style") {
                ForEach(10..<15) { index in
                    NavigationLink {
                        Text("Detail \(index)")
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.gray)
                            Text("Setting \(index)")
                            Spacer()
                            Text("Value")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowPressInteraction()
                }
            }
        }
        .navigationTitle("Interactive Rows")
    }
}

#Preview("Contacts Style") {
    NavigationStack {
        List {
            ForEach(0..<20) { index in
                NavigationLink {
                    Text("Contact Detail \(index)")
                } label: {
                    HStack(spacing: 12) {
                        // Avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(String(format: "%C", 65 + index))
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Contact Name \(index)")
                                .font(.body)
                            Text("contact\(index)@example.com")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listRowPressInteraction()
            }
        }
        .navigationTitle("Contacts")
    }
}

#Preview("Settings Style") {
    NavigationStack {
        List {
            Section {
                NavigationLink {
                    Text("Profile Detail")
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("John Appleseed")
                                .font(.body)
                            Text("Apple ID, iCloud, Media & Purchases")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .listRowPressInteraction()
            }
            
            Section {
                ForEach(["Airplane Mode", "Wi-Fi", "Bluetooth", "Cellular", "Personal Hotspot"], id: \.self) { setting in
                    NavigationLink {
                        Text("\(setting) Detail")
                    } label: {
                        HStack {
                            Image(systemName: iconName(for: setting))
                                .font(.body)
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .background(iconColor(for: setting), in: RoundedRectangle(cornerRadius: 6))
                            Text(setting)
                            Spacer()
                            if setting == "Wi-Fi" {
                                Text("MyNetwork")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listRowPressInteraction()
                }
            }
            
            Section {
                ForEach(["Notifications", "Sounds & Haptics", "Focus", "Screen Time"], id: \.self) { setting in
                    NavigationLink {
                        Text("\(setting) Detail")
                    } label: {
                        HStack {
                            Image(systemName: iconName(for: setting))
                                .font(.body)
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .background(iconColor(for: setting), in: RoundedRectangle(cornerRadius: 6))
                            Text(setting)
                        }
                    }
                    .listRowPressInteraction()
                }
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Preview Helpers

private func iconName(for setting: String) -> String {
    switch setting {
    case "Airplane Mode": return "airplane"
    case "Wi-Fi": return "wifi"
    case "Bluetooth": return "antenna.radiowaves.left.and.right"
    case "Cellular": return "antenna.radiowaves.left.and.right"
    case "Personal Hotspot": return "personalhotspot"
    case "Notifications": return "bell.badge.fill"
    case "Sounds & Haptics": return "speaker.wave.3.fill"
    case "Focus": return "moon.fill"
    case "Screen Time": return "hourglass"
    default: return "gearshape.fill"
    }
}

private func iconColor(for setting: String) -> Color {
    switch setting {
    case "Airplane Mode": return .orange
    case "Wi-Fi": return .blue
    case "Bluetooth": return .blue
    case "Cellular": return .green
    case "Personal Hotspot": return .green
    case "Notifications": return .red
    case "Sounds & Haptics": return .red
    case "Focus": return .indigo
    case "Screen Time": return .purple
    default: return .gray
    }
}

// MARK: - Haptics Helper (if not already in project)

