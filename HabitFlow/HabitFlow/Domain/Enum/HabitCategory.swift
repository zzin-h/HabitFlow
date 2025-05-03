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
        case .healthyIt: return Color(red: 116/255, green: 178/255, blue: 183/255)
        case .canDoIt: return Color(red: 234/255, green: 140/255, blue: 47/255)
        case .moneyIt: return Color(red: 255/255, green: 186/255, blue: 73/255)
        case .greenIt: return Color(red: 98/255, green: 168/255, blue: 124/255)
        case .myMindIt: return Color(red: 201/255, green: 79/255, blue: 83/255)
        }
    }
}
