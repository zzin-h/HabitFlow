//
//  HabitFlowApp.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/8/25.
//

import SwiftUI

@main
struct HabitFlowApp: App {
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HabitListView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
