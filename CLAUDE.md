# Fondy

iOS application built with SwiftUI targeting iOS 26.2.

## Build & Run

- Open `Fondy.xcodeproj` in Xcode
- Build: `xcodebuild -project Fondy.xcodeproj -scheme Fondy -sdk iphonesimulator build`
- No external dependencies (no CocoaPods, no SPM packages)

## Project Structure

```
Fondy/
├── FondyApp.swift                    # App entry point (@main, WindowGroup, auth routing)
├── ContentView.swift                 # Root TabView with bottom tab bar
├── Assets.xcassets/                  # Asset catalog (icons, colors)
├── Theme/
│   └── FondyTheme.swift              # Spacing (8pt grid), adaptive colors, haptics, animations
├── Models/
│   ├── Asset.swift                   # Investment asset data model (Identifiable)
│   ├── Portfolio.swift               # Portfolio model (@Observable) with wallet info
│   ├── AppTab.swift                  # Bottom tab bar enum (CaseIterable)
│   └── AuthState.swift               # Auth state (@Observable) — form fields, validation, flow
├── Services/
│   └── PortfolioService.swift        # Mock data provider for development/previews
└── Views/
    ├── Auth/
    │   ├── AuthContainerView.swift   # Login/SignUp switcher with slide transitions
    │   ├── LoginView.swift           # Login screen — mesh gradient, glass card, social auth
    │   ├── SignUpView.swift          # Sign-up screen — password strength, 4 fields
    │   ├── AuthTextField.swift       # Reusable text field — icon, focus ring, secure toggle
    │   └── SocialSignInButton.swift  # Apple/Google sign-in button (bordered capsule)
    ├── Components/
    │   ├── BalanceCard.swift          # Total balance (largeTitle) + performance pill
    │   ├── ActionButton.swift         # Dark capsule button with ScaleButtonStyle + haptics
    │   ├── AssetRow.swift             # Asset row with context menus, semantic colors
    │   └── WalletHeader.swift         # Wallet name + address pill badge
    └── Dashboard/
        ├── PortfolioDashboardView.swift  # Dashboard with pull-to-refresh, spring animations
        └── AssetsSection.swift           # Grouped inset card list + add button
```

## SwiftUI Best Practices & Guidelines

Follow Apple's recommended SwiftUI patterns. These rules apply to ALL code generation.

### State Management (iOS 17+ / Observation Framework)

- Use `@Observable` macro on model classes (NOT the old `ObservableObject` protocol)
- Use `@State` for view-owned model instances (replaces `@StateObject`)
- Pass observable objects to child views as plain parameters — no wrapper needed for read-only
- Use `@Bindable` for two-way bindings to `@Observable` properties (replaces `@ObservedObject`)
- Use `@Environment(MyType.self)` for dependency injection (replaces `@EnvironmentObject`)
- Do NOT use `@Published` — the `@Observable` macro handles property tracking automatically
- Every piece of state must have a single source of truth — ask "who owns this data?"

```swift
// CORRECT — Modern pattern
@Observable
class UserModel {
    var name: String = ""
    var isLoggedIn: Bool = false
}

struct ParentView: View {
    @State private var user = UserModel()
    var body: some View {
        ChildView(user: user)
    }
}

struct ChildView: View {
    @Bindable var user: UserModel
    var body: some View {
        TextField("Name", text: $user.name)
    }
}
```

### View Composition

- Keep views small, focused, and declarative — each view should do ONE thing
- Extract subviews into separate structs when a view exceeds ~40 lines
- Keep the `body` property lightweight — no heavy computation, network calls, or filtering
- Move business logic into ViewModels or `@Observable` model classes
- Use `@ViewBuilder` and `Group` to reduce view hierarchy complexity
- Prefer composition over inheritance

### Layout & Containers

- Use `LazyVStack`, `LazyHStack`, `LazyVGrid` for large scrollable lists (only renders visible items)
- Always provide stable, unique `id` values for list items (conform to `Identifiable`)
- Prefer SwiftUI's built-in layout system over manual frame calculations
- Use `ViewThatFits` for adaptive layouts

### Navigation

- Use `NavigationStack` with `navigationDestination(for:)` for programmatic navigation
- Do NOT use the deprecated `NavigationView`
- Keep navigation logic declarative — avoid Coordinator patterns in SwiftUI

### Architecture

- Favor a lightweight MVVM approach: Views render UI, `@Observable` models hold state and logic
- For simple views, `@State` alone is sufficient — don't over-engineer with a ViewModel
- Use dependency injection via `.environment()` modifier for shared services
- Keep models testable and independent of SwiftUI imports when possible

### Performance

- Minimize state updates — only mark properties that drive UI changes
- Profile with Instruments before optimizing — don't guess
- Structure data flow so views only update when their specific dependencies change
- Avoid large `@State` variables — break state into smaller pieces
- Defer side effects (network, disk) to background tasks, never in `body`

### Accessibility

- Always add `.accessibilityLabel()` to images and icons
- Use semantic views (`Label`, `Button`) over raw `Text` + `Image` combinations
- Test with VoiceOver and Dynamic Type
- Support all Dynamic Type sizes

### Previews

- Every view MUST have a `#Preview` macro
- Design views to be previewable in isolation — this drives better architecture
- Provide mock data for previews

### Concurrency

- Use Swift concurrency (`async/await`, `Task`) for asynchronous work
- Default actor isolation is `@MainActor` (project setting)
- Use `.task {}` modifier for async work tied to view lifecycle
- Never block the main thread

### Code Style

- Use Swift naming conventions: camelCase for properties/methods, PascalCase for types
- Prefer `let` over `var` when values don't change
- Use meaningful names — avoid abbreviations
- Group related properties and methods with `// MARK: -` comments
- No SwiftLint or SwiftFormat configured — follow standard Swift conventions
- Use trailing closure syntax for SwiftUI modifiers

## Build Settings

- Debug: No optimization (`-Onone`), testability enabled
- Release: Whole-module optimization, dSYM generation
- C++20 / C17 standards for interop
- Comprehensive Clang analyzer warnings enabled
- Swift concurrency: `MainActor` default isolation enabled
