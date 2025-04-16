//
//  RoutineType.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

enum RoutineType: String, Codable, CaseIterable {
    case daily
    case weekly
    case interval
    
    var title: String {
        switch self {
        case .daily: return "매일"
        case .weekly: return "요일 주기"
        case .interval: return "반복 주기"
            
        }
    }
}
