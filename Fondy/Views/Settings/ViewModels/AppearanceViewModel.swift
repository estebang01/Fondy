//
//  AppearanceViewModel.swift
//  Fondy — Settings Module
//

import SwiftUI

@Observable
final class AppearanceViewModel {

    private let store: any SettingsStoreProtocol

    init(store: any SettingsStoreProtocol) {
        self.store = store
    }

    // MARK: - Pass-through Binding

    var selectedTheme: AppTheme {
        get { store.appTheme }
        set {
            store.appTheme = newValue
            Haptics.selection()
        }
    }
}
