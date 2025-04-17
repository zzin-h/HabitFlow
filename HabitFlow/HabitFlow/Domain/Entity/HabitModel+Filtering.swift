//
//  HabitModel+Filtering.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import Foundation

extension HabitModel {
    func shouldShow(on date: Date) -> Bool {
        switch routineType {
        case .daily:
            return true

        case .weekly:
            guard let selectedDays = selectedDays,
                  let weekday = Weekdays.from(date: date)?.rawValue else { return false }
            return selectedDays.contains(weekday)

        case .interval:
            guard let interval = intervalDays else { return false }
            let diff = Calendar.current.dateComponents([.day], from: createdAt, to: date).day ?? 0
            return diff >= 0 && diff % interval == 0
        }
    }
}
