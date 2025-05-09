//
//  TimeSlot.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

enum TimeSlot: String, CaseIterable, Identifiable, Comparable {
    case am6_8, am8_10, am10_12, pm12_14, pm14_16, pm16_18, pm18_20, pm20_22, pm22_24, am0_2, am2_4, am4_6
    
    var title: String {
        switch self {
        case .am6_8: return String(localized: "time_range_6_8")
        case .am8_10: return String(localized: "time_range_8_10")
        case .am10_12: return String(localized: "time_range_10_12")
        case .pm12_14: return String(localized: "time_range_12_14")
        case .pm14_16: return String(localized: "time_range_14_16")
        case .pm16_18: return String(localized: "time_range_16_18")
        case .pm18_20: return String(localized: "time_range_18_20")
        case .pm20_22: return String(localized: "time_range_20_22")
        case .pm22_24: return String(localized: "time_range_22_24")
        case .am0_2: return String(localized: "time_range_0_2")
        case .am2_4: return String(localized: "time_range_2_4")
        case .am4_6: return String(localized: "time_range_4_6")
        }
    }

    var shortTitle: String {
        switch self {
        case .am6_8: return String(localized: "time_short_6")
        case .am8_10: return String(localized: "time_short_8")
        case .am10_12: return String(localized: "time_short_10")
        case .pm12_14: return String(localized: "time_short_12")
        case .pm14_16: return String(localized: "time_short_14")
        case .pm16_18: return String(localized: "time_short_16")
        case .pm18_20: return String(localized: "time_short_18")
        case .pm20_22: return String(localized: "time_short_20")
        case .pm22_24: return String(localized: "time_short_22")
        case .am0_2: return String(localized: "time_short_0")
        case .am2_4: return String(localized: "time_short_2")
        case .am4_6: return String(localized: "time_short_4")
        }
    }
    
    var id: String { self.rawValue }
    
    var order: Int {
        TimeSlot.allCases.firstIndex(of: self) ?? 0
    }
    
    static func slot(for hour: Int) -> TimeSlot? {
        switch hour {
        case 6..<8: return .am6_8
        case 8..<10: return .am8_10
        case 10..<12: return .am10_12
        case 12..<14: return .pm12_14
        case 14..<16: return .pm14_16
        case 16..<18: return .pm16_18
        case 18..<20: return .pm18_20
        case 20..<22: return .pm20_22
        case 22..<24: return .pm22_24
        case 0..<2: return .am0_2
        case 2..<4: return .am2_4
        case 4..<6: return .am4_6
        default: return nil
        }
    }
    
    static func < (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}
