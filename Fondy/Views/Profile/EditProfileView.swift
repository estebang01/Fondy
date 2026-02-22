//
//  EditProfileView.swift
//  Fondy
//
//  Edit profile screen showing personal information fields
//  with avatar (initials circle + camera badge) at top right.
//

import SwiftUI

struct EditProfileView: View {
    @Bindable var userProfile: UserProfile

    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoPickerSheet = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Title + Avatar row
                headerSection
                    .padding(.bottom, Spacing.sm)

                // Section header
                Text("Personal information")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(FondyColors.labelPrimary)
                    .padding(.bottom, Spacing.lg)

                // Form fields
                formFields
            }
            .padding(.horizontal, Spacing.pageMargin)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xxxl + Spacing.lg)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Haptics.light()
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(FondyColors.labelPrimary)
                }
                .accessibilityLabel("Back")
            }
        }
        .sheet(isPresented: $showPhotoPickerSheet) {
            ProfilePhotoPickerSheet()
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Header

private extension EditProfileView {

    var headerSection: some View {
        HStack(alignment: .top) {
            Text("Edit profile")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(FondyColors.labelPrimary)

            Spacer(minLength: Spacing.lg)

            // Avatar with camera badge
            Button {
                Haptics.light()
                showPhotoPickerSheet = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Text(userProfile.initials.isEmpty ? "US" : userProfile.initials)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(.systemGray), in: Circle())

                    // Camera badge
                    Image(systemName: "camera.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(.blue, in: Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGroupedBackground), lineWidth: 2)
                        )
                        .offset(x: 2, y: 2)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change profile photo")
        }
    }
}

// MARK: - Form Fields

private extension EditProfileView {

    var formFields: some View {
        VStack(spacing: Spacing.lg) {
            profileField(label: "Name", value: userProfile.fullName, isBlurred: true)
            profileField(label: "Revtag", value: "@\(userProfile.revtag)", isBlurred: true)
            profileField(label: "Date of birth", value: userProfile.dateOfBirth, isBlurred: true)
            addressField
            profileField(label: "Phone number", value: userProfile.phoneNumber, isBlurred: true)
            profileField(label: "Email", value: userProfile.email, isBlurred: true)
        }
    }

    func profileField(label: String, value: String, isBlurred: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)

            Text(value.isEmpty ? " " : value)
                .font(.body)
                .foregroundStyle(FondyColors.labelPrimary)
                .redacted(reason: isBlurred ? .placeholder : [])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }

    var addressField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Residential address")
                .font(.caption)
                .foregroundStyle(FondyColors.labelTertiary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(userProfile.residentialAddress.isEmpty ? " " : userProfile.residentialAddress)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
                    .redacted(reason: .placeholder)

                Text(userProfile.country)
                    .font(.body)
                    .foregroundStyle(FondyColors.labelPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            FondyColors.surfaceSecondary,
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditProfileView(userProfile: UserProfile.createMock())
    }
}
