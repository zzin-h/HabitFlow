//
//  TotalCompletedChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct TotalCompletedChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        VStack {
            Text("Total Completed Habits")
                .font(.title)
                .bold()

            Spacer()

            // 임시 그래프 영역 (추후 차트로 교체)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Text("Chart Coming Soon")
                        .foregroundColor(.blue)
                        .bold()
                )

            Spacer()
        }
        .padding()
    }
}
