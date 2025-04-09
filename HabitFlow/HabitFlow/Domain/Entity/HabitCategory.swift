//
//  HabitCategory.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/9/25.
//

public enum HabitCategory: String, CaseIterable {
    case healthyIt
    case canDoIt
    case moneyIt
    case greenIt
    case myMindIt      

    public var displayName: String {
        switch self {
        case .healthyIt: return "헬시잇"
        case .canDoIt:   return "할수잇"
        case .moneyIt:   return "머니잇"
        case .greenIt:   return "그린잇"
        case .myMindIt:  return "내맘잇"
        }
    }
}
