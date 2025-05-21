//
//  HabitModel+Schedule.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import Foundation

extension HabitModel {
    func isScheduled(for date: Date) -> Bool {
        switch routineType {
        case .daily:
            return true
            
        case .weekly:
            guard let selectedDays = selectedDays,
                  let weekday = Weekdays.from(date: date)?.rawValue else { return false }
            return selectedDays.contains(weekday)
            
        case .interval:
            guard let interval = intervalDays else { return false }
            let calendar = Calendar.current
            let start = calendar.startOfDay(for: createdAt)
            let target = calendar.startOfDay(for: date)
            let daysSinceCreated = calendar.dateComponents([.day], from: start, to: target).day ?? 0
            return daysSinceCreated >= 0 && daysSinceCreated % interval == 0
        }
    }
}
