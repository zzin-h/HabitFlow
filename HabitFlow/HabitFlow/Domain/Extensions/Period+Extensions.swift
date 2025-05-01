//
//  Period+Extensions.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/1/25.
//

import SwiftUI

extension Period {
    var labelText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        switch self {
        case .range:
            return "해당 기간엔"
        case .weekly:
            return "지난주"
        case .monthly(_, let month):
            return "\(month)월엔"
        }
    }
}
