//
//  StatisticsCardView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct StatisticsCardView: View {
    let title: String
    let icon: String
    let value: [String]
    let color: Color
    let actionView: StatisticsDetailType
    
    var body: some View {
        NavigationLink(destination: StatisticsDetailType.navView(route: actionView)) {
            VStack(alignment: .leading) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.largeTitle)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .padding(.vertical, 6)
                
                Text(value[0])
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(value.count > 1 ? value[1] : "없음")
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .foregroundStyle(value.count > 1 ? Color.textPrimary : .clear)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBg)
            .cornerRadius(12)
        }
    }
}
