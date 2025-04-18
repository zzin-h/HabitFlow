//
//  Weekdays+Extensions.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

import Foundation

extension Weekdays {
    static func from(date: Date) -> Weekdays? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 0: return .mon
        case 1: return .tue
        case 2: return .wed
        case 3: return .thu
        case 4: return .fri
        case 5: return .sat
        case 6: return .sun
        default: return nil
        }
    }
}
