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
            Text("주간 완료 습관")
                .font(.title2)
                .padding()

            // 예시 막대그래프
            ChartMockView(title: "월", value: 2)
            ChartMockView(title: "화", value: 4)
            ChartMockView(title: "수", value: 3)
            ChartMockView(title: "목", value: 5)
            ChartMockView(title: "금", value: 1)
            ChartMockView(title: "토", value: 6)
            ChartMockView(title: "일", value: 4)
        }
        .navigationTitle("완료한 습관 차트")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartMockView: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 40, alignment: .leading)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.blue)
                .frame(width: CGFloat(value * 20), height: 16)
            Text("\(value)")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}
