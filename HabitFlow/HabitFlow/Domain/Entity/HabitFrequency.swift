//
//  HabitFrequency.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

public enum HabitFrequency: Equatable {
    case daily
    case weekly([Int])
    case monthly(times: Int)
    case custom(intervalDays: Int)  

    public var description: String {
        switch self {
        case .daily:
            return "매일"
        case .weekly(let days):
            let dayNames = days.map { HabitFrequency.weekdayName($0) }
            return "매주 \(dayNames.joined(separator: ", "))"
        case .monthly(let times):
            return "한 달에 \(times)번"
        case .custom(let interval):
            return "\(interval)일마다"
        }
    }

    private static func weekdayName(_ index: Int) -> String {
        let names = ["일", "월", "화", "수", "목", "금", "토"]
        return names[(index - 1) % 7]
    }
}
