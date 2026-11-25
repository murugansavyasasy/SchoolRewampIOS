//
//  DashboardPopupScheduler.swift
//  School Chimes
//
//  Single global place that decides *when* the dashboard celebration popups
//  (birthday / festival) are allowed to appear.
//

import Foundation

// ============================================================================
// MARK: - ⚠️ GLOBAL NOTE — FESTIVAL POPUP IS STILL UNDER DEVELOPMENT ⚠️
// ============================================================================
//
//  The dashboard menu API (`get_dashboard_details`) sends:
//
//      "is_festival": false,
//      "festival_details": {
//          "date": "2026-11-24",
//          "name": "Tuesday holiday",
//          "content": "",
//          "url": ""
//      }
//
//  `is_festival` is still returned as `false` from the backend, so the popup
//  stays dormant on the live dashboards. Because it is decoded as an optional
//  Bool defaulting to `false`, a missing node behaves the same way.
//
//  Every `festival_details` field is optional: `FestivalWishVC` hides the title,
//  date or content it does not receive and falls back to a common festival image
//  when `url` is empty (or the download fails).
//
//  Kill switch: set `FestivalPopupConfig.isEnabled = false` to disable the
//  whole festival flow without touching the dashboards.
//
//  Display rules agreed for this feature:
//    • Festival popup → Morning, Afternoon, Evening (NOT night)
//    • Birthday popup → Morning, Evening only (NOT afternoon, NOT night)
//    • Both popups show at most once per slot per day, so returning to the
//      dashboard inside the same slot does not re-open them.
//    • When a birthday *and* a festival land on the same day, the birthday
//      popup is shown first and the festival popup follows once it is closed.
//
// ============================================================================

/// Feature switch for the festival popup. See the global note above.
enum FestivalPopupConfig {
    /// Under development — flip to `false` to stop the festival popup entirely.
    static let isEnabled = true
}

/// The part of the day the user is currently in.
enum DashboardDaySlot: String {
    case morning
    case afternoon
    case evening
    case night
}

/// Celebration popups that the dashboards can present.
enum DashboardCelebrationPopup: String {
    case birthday
    case festival

    /// Slots in which this popup is allowed to appear.
    var allowedSlots: [DashboardDaySlot] {
        switch self {
        case .birthday:
            return [.morning, .evening]
        case .festival:
            return [.morning, .afternoon, .evening]
        }
    }
}

final class DashboardPopupScheduler {

    static let shared = DashboardPopupScheduler()
    private let defaults = UserDefaults.standard
    private init() {}

    /// Morning 5AM–12PM, Afternoon 12PM–4PM, Evening 4PM–9PM, Night otherwise.
    var currentSlot: DashboardDaySlot {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return .morning
        case 12..<16: return .afternoon
        case 16..<21: return .evening
        default:      return .night
        }
    }

    /// `true` when the popup is allowed in the current slot and has not already
    /// been shown in that slot today.
    func canShow(_ popup: DashboardCelebrationPopup) -> Bool {
        let slot = currentSlot
        guard popup.allowedSlots.contains(slot) else { return false }
        return defaults.string(forKey: storageKey(for: popup)) != stamp(for: slot)
    }

    /// Remembers that the popup was presented in the current slot.
    func markShown(_ popup: DashboardCelebrationPopup) {
        defaults.set(stamp(for: currentSlot), forKey: storageKey(for: popup))
    }

    // MARK: - Helpers

    private func storageKey(for popup: DashboardCelebrationPopup) -> String {
        "dashboard_popup_last_shown_\(popup.rawValue)"
    }

    /// One stamp per day + slot, e.g. `2026-11-24_morning`.
    private func stamp(for slot: DashboardDaySlot) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: Date()))_\(slot.rawValue)"
    }
}
