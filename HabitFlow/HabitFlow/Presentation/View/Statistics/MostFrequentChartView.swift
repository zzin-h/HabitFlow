//
//  MostFrequentChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/29/25.
//

import SwiftUI
import Charts

struct MostFrequentChartView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var selectedMostFrequent: MostFrequentCategory = .weekDays
    
    var body: some View {
        VStack {
            Picker("카테고리", selection: $selectedMostFrequent) {
                ForEach(MostFrequentCategory.allCases, id: \.self) { stat in
                    Text(stat.title).tag(stat)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedMostFrequent {
            case .weekDays:
                WeekdayGraphView(stats: viewModel.weekdayStats)
                WeekdayTop3SummaryView(viewModel: viewModel)
            case .timeSlots:
                TimeSlotGraphView(stats: viewModel.timeSlotStats)
                TimeSlotTop3SummaryView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadTimePatternStats()
        }
    }
}

struct WeekdayGraphView: View {
    let stats: [WeekdayStat]
    
    var body: some View {
        Chart {
            ForEach(stats.sorted(by: { $0.weekday < $1.weekday }), id: \.weekday) { stat in
                BarMark(
                    x: .value("요일", stat.weekday.koreanTitle),
                    y: .value("횟수", stat.count)
                )
                .foregroundStyle(by: .value("요일", stat.weekday.koreanTitle))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 250)
        .padding()
    }
}

struct WeekdayTop3SummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        ForEach(viewModel.top3Weekdays) { stat in
            Text("\(stat.weekday.koreanTitle): \(stat.count)회")
        }
    }
}

struct TimeSlotGraphView: View {
    let stats: [TimeSlotStat]
    
    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(stats.sorted(by: { $0.slot < $1.slot }), id: \.slot) { stat in
                    BarMark(
                        x: .value("시간대", stat.slot.title),
                        y: .value("빈도", stat.count)
                    )
                    .foregroundStyle(by: .value("시간대", stat.slot.title))
                }
            }
            .chartXAxis {
                AxisMarks(values: stats.map { $0.slot.title })
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(width: UIScreen.main.bounds.width * 1.5, height: 250)
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

struct TimeSlotTop3SummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    var body: some View {
        ForEach(viewModel.top3TimeSlots) { stat in
            Text("\(stat.slot.title): \(stat.count)회")
        }
    }
}
