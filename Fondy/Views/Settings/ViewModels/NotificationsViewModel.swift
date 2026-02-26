//
//  NotificationsViewModel.swift
//  Fondy — Settings Module
//

import SwiftUI

@Observable
final class NotificationsViewModel {

    private let store: any SettingsStoreProtocol

    init(store: any SettingsStoreProtocol) {
        self.store = store
    }

    // MARK: - Computed

    var categories: [NotificationCategory] { store.notificationCategories }

    var allEnabled: Bool { store.notificationCategories.allSatisfy { $0.isEnabled } }
    var noneEnabled: Bool { store.notificationCategories.allSatisfy { !$0.isEnabled } }

    // MARK: - Actions

    func toggle(categoryId: String) {
        guard let i = store.notificationCategories.firstIndex(where: { $0.id == categoryId }) else { return }
        store.notificationCategories[i].isEnabled.toggle()
        Haptics.selection()
    }

    func enableAll() {
        for i in store.notificationCategories.indices {
            store.notificationCategories[i].isEnabled = true
        }
        Haptics.selection()
    }

    func disableAll() {
        for i in store.notificationCategories.indices {
            store.notificationCategories[i].isEnabled = false
        }
        Haptics.selection()
    }
}
