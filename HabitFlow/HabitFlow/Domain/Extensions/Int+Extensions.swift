//
//  Int+Extensions.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/17/25.
//

import Foundation

extension Int {
    var formattedTime: String {
        String(format: "%02d:%02d", self / 60, self % 60)
    }
}
