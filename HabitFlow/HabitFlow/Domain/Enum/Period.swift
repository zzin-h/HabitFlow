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
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return weekStart...weekEnd
            
        case .monthly(let year, let month):
            var components = DateComponents(year: year, month: month)
            let start = calendar.date(from: components)!
            components.month! += 1
            let end = calendar.date(from: components)!
            return start...end
        }
    }
}
