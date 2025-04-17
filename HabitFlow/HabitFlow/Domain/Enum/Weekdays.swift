//
//  Weekdays.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/16/25.
//

enum Weekdays: String, Codable, CaseIterable, Comparable {
    case sun, mon, tue, wed, thu, fri, sat

    var koreanTitle: String {
        switch self {
        case .sun: return "일"
        case .mon: return "월"
        case .tue: return "화"
        case .wed: return "수"
        case .thu: return "목"
        case .fri: return "금"
        case .sat: return "토"
        }
    }

    static func < (lhs: Weekdays, rhs: Weekdays) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
