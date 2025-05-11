//
//  HabitNotificationView.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/10/25.
//

import SwiftUI

struct HabitNotificationView: View {
    @ObservedObject var viewModel: HabitNotificationViewModel
    let habitId: UUID
    
    var body: some View {
        HStack(spacing: 4) {
            if viewModel.isNotificationOn {
                Image(systemName: "bell.badge.fill")
                Text(formattedTime(viewModel.notificationTime))
            }
        }
        .onAppear {
            viewModel.setHabitId(habitId)
        }
    }
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("hmma")
        return formatter.string(from: date)
    }
}
