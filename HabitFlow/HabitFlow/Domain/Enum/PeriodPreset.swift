//
//  PeriodPreset.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import SwiftUI

enum PeriodPreset: String, CaseIterable, Identifiable {
    case oneWeek = "1주"
    case oneMonth = "1개월"
//    case threeMonths = "3개월"
//    case oneYear = "1년"

    var id: String { rawValue }

    func toPeriod() -> Period {
        let now = Date()
        let calendar = Calendar.current

        switch self {
        case .oneWeek:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            return .range(start: start, end: now)

        case .oneMonth:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return .range(start: start, end: now)

//        case .threeMonths:
//            let start = calendar.date(byAdding: .month, value: -3, to: now)!
//            return .range(start: start, end: now)
//
//        case .oneYear:
//            let start = calendar.date(byAdding: .year, value: -1, to: now)!
//            return .range(start: start, end: now)
        }
    }
}
