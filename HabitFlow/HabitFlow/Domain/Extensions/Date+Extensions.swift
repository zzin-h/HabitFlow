//
//  Date+Extensions.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import Foundation

extension Date {
    func weekdayShortSymbol(locale: Locale = Locale(identifier: "ko_KR")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }
}
