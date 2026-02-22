//
//  HelpArticleView.swift
//  Fondy
//
//  Created by Assistant on 14/02/26.
//

import SwiftUI

/// Minimal placeholder to resolve missing reference build errors.
/// Replace with your real implementation when ready.
struct HelpArticleView: View {
    let title: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.title.bold())
                Text("This is a placeholder Help screen. Add your help content here.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack { HelpArticleView(title: "Help") }
}
