//
//  RoutineSummaryView.swift
//  HabitFlow
//
//  Created by Haejin Park on 5/1/25.
//

import SwiftUI

struct RoutineSummaryView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    @State private var period: Period = .weekly(Date())
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let summary = viewModel.routineSummary {
                Text("\(period.labelText) \(summary.routineCount)개의 루틴을 \(summary.totalCount)회 실천했어요!")
                
                let name = summary.topRoutineName.joined(separator: ", ")
                Text("가장 많이 실천한 습관은 \(name) 💪")
                
                if let weekday = summary.topWeekday, let time = summary.topTimeSlot {
                    Text("주로 \(weekday.koreanTitle) \(time.title)에 활발했어요!")
                }
                
                if formatHour(summary.totalDuration) > 0 {
                    Text("총 \(formatHour(summary.totalDuration))시간 \(formatMin(summary.totalDuration))분 동안 자신을 위해 썼어요.")
                } else {
                    Text("총 \(formatMin(summary.totalDuration))분 동안 자신을 위해 썼어요.")
                }
            } else {
                Text("충분한 데이터가 없어요!")
            }
        }
        .onAppear{
            viewModel.loadSummary(for: period)
        }
    }
    
    private func formatHour(_ time: Int) -> Int {
        let hour = Int(time) / 60
        return hour
    }
    
    private func formatMin(_ time: Int) -> Int {
        let min = Int(time) % 60
        return min
    }
}
