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
            
            if viewModel.weekdayStats.isEmpty {
                Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
                    .foregroundStyle(Color.gray)
                    .padding(.top, 32)
            } else {
                switch selectedMostFrequent {
                case .weekDays:
                    WeekdayGraphView(stats: viewModel.weekdayStats)
                        .frame(height: UIScreen.main.bounds.height * 0.45)
                    
                    Divider()
                    
                    WeekdayTop3SummaryView(viewModel: viewModel)
                case .timeSlots:
                    TimeSlotGraphView(stats: viewModel.timeSlotStats)
                        .frame(height: UIScreen.main.bounds.height * 0.45)
                    
                    Divider()
                    
                    TimeSlotTop3SummaryView(viewModel: viewModel)
                }
            }
        }
        .navigationTitle(String(localized: "most_frequent"))
        .onAppear {
            viewModel.loadTimePatternStats()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > -50 {
                        selectedMostFrequent = .weekDays
                    } else if value.translation.width < 50 {
                        selectedMostFrequent = .timeSlots
                    }
                }
        )
    }
}

struct WeekdayGraphView: View {
    let stats: [WeekdayStat]
    
    var body: some View {
        Chart {
            ForEach(stats.sorted(by: { $0.weekday < $1.weekday }), id: \.weekday) { stat in
                BarMark(
                    x: .value("요일", stat.weekday.shortTitle),
                    y: .value("횟수", stat.count)
                )
                .foregroundStyle(Color.secondaryColor)
                .annotation(position: .top) {
                    if stat.count > 0 {
                        Text("\(stat.count)" + NSLocalizedString("times_en_none", comment: "times_en_none"))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
    }
}

struct WeekdayTop3SummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    private var top1: WeekdayStat? {
        viewModel.top3Weekdays.indices.contains(0) ? viewModel.top3Weekdays[0] : nil
    }
    private var top2: WeekdayStat? {
        viewModel.top3Weekdays.indices.contains(1) ? viewModel.top3Weekdays[1] : nil
    }
    private var top3: WeekdayStat? {
        viewModel.top3Weekdays.indices.contains(2) ? viewModel.top3Weekdays[2] : nil
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("best_3", comment: "best_3"))
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.textPrimary)
                    .padding(.bottom, 16)
                
                if let top1 {
                    Top3Card(title: top1.weekday.fullTitle,
                             count: top1.count,
                             crownColor: .yellow,
                             font: .title3
                    )
                }
                if let top2 {
                    Top3Card(title: top2.weekday.fullTitle,
                             count: top2.count,
                             crownColor: .gray,
                             font: .headline
                    )
                }
                
                if let top3 {
                    Top3Card(title: top3.weekday.fullTitle,
                             count: top3.count,
                             crownColor: Color(red: 205/255, green: 127/255, blue: 50/255),
                             font: .headline
                    )
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct TimeSlotGraphView: View {
    let stats: [TimeSlotStat]
    
    var body: some View {
        VStack {
            Chart {
                ForEach(stats.sorted(by: { $0.slot < $1.slot }), id: \.slot) { stat in
                    BarMark(
                        x: .value("시간대", stat.slot.shortTitle),
                        y: .value("빈도", stat.count)
                    )
                    .annotation(position: .top) {
                        if stat.count > 0 {
                            Text("\(stat.count)" + NSLocalizedString("times_en_none", comment: "times_en_none"))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 4)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: stats.map { $0.slot.shortTitle })
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
        }
    }
}

private struct TimeSlotTop3SummaryView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    private var top1: TimeSlotStat? {
        viewModel.top3TimeSlots.indices.contains(0) ? viewModel.top3TimeSlots[0] : nil
    }
    private var top2: TimeSlotStat? {
        viewModel.top3TimeSlots.indices.contains(1) ? viewModel.top3TimeSlots[1] : nil
    }
    private var top3: TimeSlotStat? {
        viewModel.top3TimeSlots.indices.contains(2) ? viewModel.top3TimeSlots[2] : nil
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("best_3", comment: "best_3"))
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.textPrimary)
                    .padding(.bottom, 16)
                
                if let top1 {
                    Top3Card(title: top1.slot.title,
                             count: top1.count,
                             crownColor: .yellow,
                             font: .title3
                    )
                }
                if let top2 {
                    Top3Card(title: top2.slot.title,
                             count: top2.count,
                             crownColor: .gray,
                             font: .headline
                    )
                }
                
                if let top3 {
                    Top3Card(title: top3.slot.title,
                             count: top3.count,
                             crownColor: Color(red: 205/255, green: 127/255, blue: 50/255),
                             font: .headline
                    )
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct Top3Card: View {
    let title: String
    let count: Int
    let crownColor: Color
    let font: Font
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                
                Image(systemName: "crown.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(crownColor)
                
                Text(title)
                    .bold()
                
                Spacer()
                Spacer()
                Spacer()
                
                Text("\(count)" + NSLocalizedString("times", comment: "times"))
                    .foregroundStyle(Color.textSecondary)
                    .fontWeight(.regular)
                
                Spacer()
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.vertical, 16)
        }
        .font(font)
        .background(Color.cardBg)
        .cornerRadius(8)
    }
}
