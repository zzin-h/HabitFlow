//
//  Weekdays.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation

enum Weekdays: String, Codable, CaseIterable, Comparable {
    case sun, mon, tue, wed, thu, fri, sat

    var index: Int {
        switch self {
        case .sun: return 0
        case .mon: return 1
        case .tue: return 2
        case .wed: return 3
        case .thu: return 4
        case .fri: return 5
        case .sat: return 6
        }
    }

    var shortTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[index]
    }

    var fullTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[index]
    }

    static func < (lhs: Weekdays, rhs: Weekdays) -> Bool {
        lhs.index < rhs.index
    }
}
