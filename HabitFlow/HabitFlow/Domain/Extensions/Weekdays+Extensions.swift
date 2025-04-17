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
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        case 7: return .sat
        default: return nil
        }
    }
}
