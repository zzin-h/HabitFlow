//
//  RoutineType.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

enum RoutineType: String, Codable, CaseIterable {
    case daily, weekly, interval
    
    var title: String {
        switch self {
        case .daily: return String(localized: "every_days")
        case .weekly: return String(localized: "weekday")
        case .interval: return String(localized: "custom")
            
        }
    }
}
