//
//  SettingsView.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/6/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        Form {
            Picker(String(localized: "appearance"), selection: $colorSchemeManager.selectedScheme) {
                Text(NSLocalizedString("light_mode", comment: "light_mode")).tag("light")
                Text(NSLocalizedString("dark_mode", comment: "dark_mode")).tag("dark")
            }
            .pickerStyle(.menu)
        }
        .navigationTitle(String(localized: "settings_nav_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
