//
//  ProfilePhotoPickerSheet.swift
//  Fondy
//
//  Bottom sheet for choosing a profile photo.
//  Shows a horizontal scrollable thumbnail strip (camera + recent photos)
//  and a "Choose from Gallery" button.
//

import SwiftUI

struct ProfilePhotoPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Thumbnail strip
            thumbnailStrip

            // Choose from Gallery button
            galleryButton
        }
        .padding(.top, Spacing.xl)
        .padding(.bottom, Spacing.xl)
        .background(FondyColors.background)
    }
}

// MARK: - Thumbnail Strip

private extension ProfilePhotoPickerSheet {

    var thumbnailStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // Camera option
                cameraButton

                // Mock photo thumbnails
                ForEach(0..<4, id: \.self) { index in
                    photoThumbnail(index: index)
                }
            }
            .padding(.horizontal, Spacing.pageMargin)
        }
    }

    var cameraButton: some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(width: 120, height: 160)

                Image(systemName: "camera.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(FondyColors.labelSecondary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Take photo")
    }

    func photoThumbnail(index: Int) -> some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(thumbnailColor(for: index))
                .frame(width: 120, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(FondyColors.separator.opacity(0.3), lineWidth: 0.5)
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Photo \(index + 1)")
    }

    func thumbnailColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(.systemGray5),
            Color(.systemGray4),
            Color(.systemGray5),
            Color(.systemGray4)
        ]
        return colors[index % colors.count]
    }
}

// MARK: - Gallery Button

private extension ProfilePhotoPickerSheet {

    var galleryButton: some View {
        Button {
            Haptics.light()
            dismiss()
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: "photo.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)

                Text("Choose from Gallery")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.blue)

                Spacer()
            }
            .padding(Spacing.lg)
            .background(
                FondyColors.surfaceSecondary,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, Spacing.pageMargin)
    }
}

// MARK: - Preview

#Preview {
    ProfilePhotoPickerSheet()
        .presentationDetents([.height(320)])
}
