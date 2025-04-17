//
//  HabitModel+Complete.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import Foundation

extension HabitModel {
    func isCompleted(on date: Date, with records: [HabitRecordModel]) -> Bool {
        records.contains { record in
            record.habit.id == self.id &&
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
}
