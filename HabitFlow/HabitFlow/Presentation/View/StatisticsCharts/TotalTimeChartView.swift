//
//  TotalTimeChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import SwiftUI
import Charts

struct TotalTimeChartView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Picker("카테고리", selection: $viewModel.selectedCategory) {
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if viewModel.filteredTotalTimeStats.isEmpty {
                Text("데이터가 없습니다")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TotalTimeGraphView(viewModel: viewModel)
                
                TotalTime3Summary(viewModel: viewModel)
                
                Divider()
                
                TotalTimeSummaryByCategory(viewModel: viewModel)
            }
        }
        .navigationTitle("총 사용 시간")
        .onAppear {
            viewModel.loadTotalTimeStats()
        }
    }
}

private struct TotalTimeGraphView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart(viewModel.filteredTotalTimeStats) { stat in
                BarMark(
                    x: .value("누적 시간 (분)", stat.duration),
                    y: .value("습관", stat.title)
                )
                .foregroundStyle(by: .value("습관", stat.title))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4)
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}

private struct TotalTime3Summary: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        VStack {
            Text("Top 3 목표시간 습관")
            ForEach(viewModel.top3DurationHabits) { habit in
                Text("\(habit.title): \(habit.duration)분 : \(habit.category.title)")
            }
        }
    }
}

private struct TotalTimeSummaryByCategory: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        ForEach(viewModel.filteredTotalTimeStats) { habit in
            Text("\(habit.title): \(habit.duration)분")
        }
    }
}
