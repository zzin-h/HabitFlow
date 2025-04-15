//
//  HabitCategory.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

enum HabitCategory: String, CaseIterable {
    case healthyIt
    case canDoIt
    case moneyIt
    case greenIt
    case myMindIt

    var displayName: String {
        switch self {
        case .healthyIt: return "헬시잇"
        case .canDoIt:   return "할수잇"
        case .moneyIt:   return "머니잇"
        case .greenIt:   return "그린잇"
        case .myMindIt:  return "내맘잇"
        }
    }
}
