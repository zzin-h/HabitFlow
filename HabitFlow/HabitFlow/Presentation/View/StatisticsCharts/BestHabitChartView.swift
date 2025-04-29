//
//  BestHabitChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import SwiftUI
import Charts

struct BestHabitChartView: View {
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
            
            if viewModel.filteredHabits.isEmpty {
                Text("데이터가 없습니다")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                BestHabitGraphView(viewModel: viewModel)
                
                BestHabit3Summary(viewModel: viewModel)
                
                Divider()
                
                HabitSummaryByCategory(viewModel: viewModel)
            }
        }
        .navigationTitle("카테고리별 습관")
        .onAppear {
            viewModel.loadAllBestHabits()
        }
    }
}

private struct BestHabitGraphView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart(viewModel.filteredHabits) { habit in
                BarMark(
                    x: .value("횟수", habit.count),
                    y: .value("습관", habit.title)
                )
                .foregroundStyle(by: .value("습관", habit.title))
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

private struct BestHabit3Summary: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        VStack {
            Text("Top 3 습관")
            ForEach(viewModel.top3Habits) { habit in
                Text("\(habit.title): \(habit.count)회 : \(habit.category.title)")
            }
        }
    }
}

private struct HabitSummaryByCategory: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        ForEach(viewModel.filteredHabits) { habit in
            Text("\(habit.title): \(habit.count)회")
        }
    }
}
