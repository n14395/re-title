// Copyright 2026 Nick Fay
// SPDX-License-Identifier: Apache-2.0

import SwiftUI

// MARK: - Focused Value Keys

/// Key for accessing the RenameViewModel from menu commands
struct RenameViewModelKey: FocusedValueKey {
    typealias Value = RenameViewModel
}

/// Key for accessing file selection state from menu commands
struct SelectedFileIDsKey: FocusedValueKey {
    typealias Value = Binding<Set<UUID>>
}

/// Key for controlling onboarding visibility from menu commands
struct ShowOnboardingKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

// MARK: - FocusedValues Extension

extension FocusedValues {
    /// The active RenameViewModel for menu commands
    var renameViewModel: RenameViewModel? {
        get { self[RenameViewModelKey.self] }
        set { self[RenameViewModelKey.self] = newValue }
    }
    
    /// Binding to the currently selected file IDs
    var selectedFileIDs: Binding<Set<UUID>>? {
        get { self[SelectedFileIDsKey.self] }
        set { self[SelectedFileIDsKey.self] = newValue }
    }
    
    /// Binding to control onboarding visibility
    var showOnboarding: Binding<Bool>? {
        get { self[ShowOnboardingKey.self] }
        set { self[ShowOnboardingKey.self] = newValue }
    }
}
