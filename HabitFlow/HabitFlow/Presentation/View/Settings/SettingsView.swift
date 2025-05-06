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
            Picker("화면모드 설정", selection: $colorSchemeManager.selectedScheme) {
                Text("라이트 모드").tag("light")
                Text("다크 모드").tag("dark")
                Text("시스템 설정").tag("system")
            }
            .pickerStyle(.menu)
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}
