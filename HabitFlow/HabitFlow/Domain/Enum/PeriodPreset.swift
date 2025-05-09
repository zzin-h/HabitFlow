//
//  PeriodPreset.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import SwiftUI

enum PeriodPreset: String, CaseIterable, Identifiable {
    case oneWeek, oneMonth

    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .oneWeek: return String(localized: "7_days")
        case .oneMonth: return String(localized: "30_days")
            
        }
    }

    func toPeriod() -> Period {
        let now = Date()
        let calendar = Calendar.current

        switch self {
        case .oneWeek:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            return .range(start: start, end: now)

        case .oneMonth:
            let start = calendar.date(byAdding: .day, value: -29, to: now)!
            return .range(start: start, end: now)
        }
    }
}
