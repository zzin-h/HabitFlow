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
        case .am6_8: return "06 ~ 08시"
        case .am8_10: return "08 ~ 10시"
        case .am10_12: return "10 ~ 12시"
        case .pm12_14: return "12 ~ 14시"
        case .pm14_16: return "14 ~ 16시"
        case .pm16_18: return "16 ~ 18시"
        case .pm18_20: return "18 ~ 20시"
        case .pm20_22: return "20 ~ 22시"
        case .pm22_24: return "22 ~ 24시"
        case .am0_2: return "00 ~ 02시"
        case .am2_4: return "02 ~ 04시"
        case .am4_6: return "04 ~ 06시"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .am6_8: return "06시"
        case .am8_10: return "08시"
        case .am10_12: return "10시"
        case .pm12_14: return "12시"
        case .pm14_16: return "14시"
        case .pm16_18: return "16시"
        case .pm18_20: return "18시"
        case .pm20_22: return "20시"
        case .pm22_24: return "22시"
        case .am0_2: return "24시"
        case .am2_4: return "02시"
        case .am4_6: return "04시"
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
