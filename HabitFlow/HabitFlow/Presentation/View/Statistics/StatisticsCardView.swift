//
//  StatisticsCardView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct StatisticsCardView: View {
    let item: StatisticsOverviewItemModel

    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .font(.title2)
                .padding()
                .background(item.backgroundColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.valueDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
