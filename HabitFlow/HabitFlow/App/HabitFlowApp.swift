//
//  HabitFlowApp.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/8/25.
//

import SwiftUI

@main
struct HabitFlowApp: App {
    init() {
        AppLaunchManager.shared.initializeApp()
    }
    
    var body: some Scene {
        WindowGroup {
            TodayHabitView()
        }
    }
}
