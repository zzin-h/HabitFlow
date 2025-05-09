//
//  MostFrequentCategory.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

enum MostFrequentCategory: String, Codable, CaseIterable, Identifiable {
    case weekDays, timeSlots
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .weekDays: return String(localized: "weekday")
        case .timeSlots: return String(localized: "time_period")
        }
    }
}
