//
//  PeriodPreset.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import SwiftUI

enum PeriodPreset: String, CaseIterable, Identifiable {
    case today = "오늘"
    case thisWeek = "이번 주"
    case thisMonth = "이번 달"

    var id: String { rawValue }

    func toPeriod() -> Period {
        let now = Date()
        let calendar = Calendar.current
        switch self {
        case .today:
            return .daily(now)
        case .thisWeek:
            return .weekly(now)
        case .thisMonth:
            let components = calendar.dateComponents([.year, .month], from: now)
            return .monthly(year: components.year ?? 2024, month: components.month ?? 1)
        }
    }
}
