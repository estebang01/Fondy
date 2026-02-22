//
//  FondyApp.swift
//  Fondy
//
//  Created by Esteban Gómez Gómez on 8/02/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FondyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authState = AuthState()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app content — rendered underneath so it's ready
                appContent

                // Splash sits on top and fades away
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                // Run session check and enforce a minimum display time in parallel,
                // then dismiss the splash only when both have finished.
                await withTaskGroup(of: Void.self) { group in
                    group.addTask { await authState.checkSession() }
                    group.addTask { try? await Task.sleep(for: .seconds(1.8)) }
                    for await _ in group { }
                }
                withAnimation(.easeInOut(duration: 0.45)) {
                    showSplash = false
                }
            }
        }
    }

    @ViewBuilder
    private var appContent: some View {
        Group {
            if authState.isAuthenticated {
            } else if !authState.hasSeenOnboarding {
                OnboardingView {
                    withAnimation(.springGentle) {
                        authState.hasSeenOnboarding = true
                        authState.currentScreen = .phoneSignUp
                    }
                }
                .transition(.opacity)
            } else {
                AuthContainerView(authState: authState)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.springGentle, value: authState.isAuthenticated)
        .animation(.springGentle, value: authState.hasSeenOnboarding)
    }
}
