//
//  Period.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation

enum Period: Hashable {
    case range(start: Date, end: Date)
    case weekly(Date)
    case monthly(year: Int, month: Int)
    
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        switch self {
        case .range(let start, let end):
            return calendar.startOfDay(for: start)...calendar.startOfDay(for: end)
            
        case .weekly(let date):
            let weekday = calendar.component(.weekday, from: date)
            let daysToSubtract = weekday == 1 ? 7 : weekday - 1
            let thisWeekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: date))!
            let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: thisWeekStart)!
            let lastWeekEnd = calendar.date(byAdding: .day, value: 7, to: lastWeekStart)!
            return lastWeekStart...lastWeekEnd
            
        case .monthly(let year, let month):
            var currentMonthComponents = DateComponents(year: year, month: month)
            let thisMonthStart = calendar.date(from: currentMonthComponents)!
            let lastMonthEnd = thisMonthStart
            currentMonthComponents.month! -= 1
            let lastMonthStart = calendar.date(from: currentMonthComponents)!
            return lastMonthStart...lastMonthEnd
        }
    }
}
