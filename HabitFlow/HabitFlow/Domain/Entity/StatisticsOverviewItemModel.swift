//
//  StatisticsOverviewItemModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import SwiftUI

struct StatisticsOverviewItemModel: Identifiable {
    let id = UUID()
    let type: StatisticsDetailType
    let title: String
    let valueDescription: String
    let icon: String
    let backgroundColor: Color
}
