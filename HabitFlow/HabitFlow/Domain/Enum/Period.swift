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
            let daysSinceMonday = (weekday + 5) % 7
            let thisMonday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: calendar.startOfDay(for: date))!
            let lastMonday = calendar.date(byAdding: .day, value: -7, to: thisMonday)!
            let lastSunday = calendar.date(byAdding: .day, value: 6, to: lastMonday)!
            return lastMonday...lastSunday
            
        case .monthly(let year, let month):
            let now = Date()
            let day = Calendar.current.component(.day, from: now)
            let currentMonthComponents = DateComponents(year: year, month: month, day: day)
            
            let calendar = Calendar.current
            let thisMonthToday = calendar.date(from: currentMonthComponents) ?? calendar.date(from: DateComponents(year: year, month: month + 1, day: 0))!
            
            let endDate = calendar.startOfDay(for: thisMonthToday)
            let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
            
            return startDate...endDate
        }
    }
}
