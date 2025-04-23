//
//  Period.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation

enum Period: Hashable {
    case daily(Date)
    case weekly(Date)
    case monthly(year: Int, month: Int)
    case custom(start: Date, end: Date)

    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        switch self {
        case .daily(let date):
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return start...end

        case .weekly(let date):
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return weekStart...weekEnd

        case .monthly(let year, let month):
            var components = DateComponents(year: year, month: month)
            let start = calendar.date(from: components)!
            components.month! += 1
            let end = calendar.date(from: components)!
            return start...end

        case .custom(let start, let end):
            return start...end
        }
    }
}
