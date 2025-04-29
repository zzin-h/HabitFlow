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
        case .weekDays: return "요일"
        case .timeSlots: return "시간대"
        }
    }
}
