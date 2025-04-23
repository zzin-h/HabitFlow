//
//  HabitCategory.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/15/25.
//

import SwiftUI

enum HabitCategory: String, Codable, CaseIterable {
    case healthyIt, canDoIt, moneyIt, greenIt, myMindIt

    var title: String {
        switch self {
        case .healthyIt: return "헬시잇"
        case .canDoIt: return "할수잇"
        case .moneyIt: return "머니잇"
        case .greenIt: return "그린잇"
        case .myMindIt: return "내맘잇"
        }
    }

    var color: Color {
        switch self {
        case .healthyIt: return .green
        case .canDoIt: return .blue
        case .moneyIt: return .yellow
        case .greenIt: return .mint
        case .myMindIt: return .pink
        }
    }
}
