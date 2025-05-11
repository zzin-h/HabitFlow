//
//  ColorSchemeManager.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/6/25.
//

import SwiftUI

class ColorSchemeManager: ObservableObject {
    @AppStorage("selectedColorScheme") var selectedScheme: String = "light" {
        didSet {
            objectWillChange.send()
        }
    }

    var currentScheme: ColorScheme? {
        switch selectedScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
