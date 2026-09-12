import SwiftUI
import StoreKit

// MARK: - App Store Review Prompt
//
// Decides *when it's polite* to ask for a review. It does NOT control whether the system
// dialog appears — requestReview() is only a request, and the OS enforces Apple's cap of
// 3 prompts per user per 365 days for us. Trigger policy: only after a real core action,
// a few days after install, and at most once per app version.
enum ReviewPrompt {
    private static let defaults = UserDefaults.standard
    private static let installDateKey = "reviewPrompt.installDate"
    private static let actionCountKey = "reviewPrompt.actionCount"
    private static let lastVersionKey = "reviewPrompt.lastPromptedVersion"
    private static let minDaysSinceInstall = 3
    private static let minCoreActions = 5

    private static var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    static func registerLaunch() {
        if defaults.object(forKey: installDateKey) == nil {
            defaults.set(Date(), forKey: installDateKey)
        }
    }
    static func registerCoreAction() {
        defaults.set(defaults.integer(forKey: actionCountKey) + 1, forKey: actionCountKey)
    }
    @MainActor
    static func requestIfAppropriate(_ requestReview: RequestReviewAction) {
        guard let installDate = defaults.object(forKey: installDateKey) as? Date else { return }
        let days = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        guard days >= minDaysSinceInstall,
              defaults.integer(forKey: actionCountKey) >= minCoreActions,
              defaults.string(forKey: lastVersionKey) != currentAppVersion
        else { return }
        defaults.set(currentAppVersion, forKey: lastVersionKey)
        requestReview()
    }
}
