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
                Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
                    .foregroundStyle(Color.gray)
                    .padding(.top, 32)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
            } else {
                TotalTimeGraphView(viewModel: viewModel)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .padding(.horizontal)
            }
            Divider()
            
            TotalTime3Summary(viewModel: viewModel)
        }
        .navigationTitle(String(localized: "total_time"))
        .onAppear {
            viewModel.loadTotalTimeStats()
        }
    }
}

private struct TotalTimeGraphView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    private var barHeight: CGFloat {
        if viewModel.filteredTotalTimeStats.count < 5 {
            return 120
        } else if viewModel.filteredTotalTimeStats.count < 7 {
            return 100
        } else if viewModel.filteredTotalTimeStats.count < 9 {
            return 180
        } else if viewModel.filteredTotalTimeStats.count < 11 {
            return 60
        } else {
            return 40
        }
    }
    
    var body: some View {
        ScrollView {
            Chart(viewModel.filteredTotalTimeStats.sorted(by: { $0.duration > $1.duration })) { habit in
                BarMark(
                    x: .value("누적 시간 (분)", habit.duration),
                    y: .value("습관", habit.title)
                )
                .foregroundStyle(habit.category.color)
                .annotation(position: .trailing) {
                    Text("\(habit.duration) " + NSLocalizedString("mins", comment: "mins"))
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: CGFloat(viewModel.filteredTotalTimeStats.count) * barHeight)
            
            Spacer()
        }
    }
}

private struct TotalTime3Summary: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    
    private var top1: TotalTimeStat? {
        viewModel.top3DurationHabits.indices.contains(0) ? viewModel.top3DurationHabits[0] : nil
    }
    private var top2: TotalTimeStat? {
        viewModel.top3DurationHabits.indices.contains(1) ? viewModel.top3DurationHabits[1] : nil
    }
    private var top3: TotalTimeStat? {
        viewModel.top3DurationHabits.indices.contains(2) ? viewModel.top3DurationHabits[2] : nil
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("best_3", comment: "best_3"))
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.textPrimary)
                        .padding(.bottom, 16)
                    
                    Spacer()
                }
                
                if let top1 {
                    Top3Card(title: top1.title,
                             duration: top1.duration,
                             category: top1.category.title,
                             crownColor: .yellow,
                             font: .title3
                    )
                }
                
                HStack(spacing: 8) {
                    if let top2 {
                        Top3Card(title: top2.title,
                                 duration: top2.duration,
                                 category: top2.category.title,
                                 crownColor: .gray,
                                 font: .headline
                        )
                    }
                    
                    if let top3 {
                        Top3Card(title: top3.title,
                                 duration: top3.duration,
                                 category: top3.category.title,
                                 crownColor: Color(red: 205/255, green: 127/255, blue: 50/255),
                                 font: .headline
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct Top3Card: View {
    let title: String
    let duration: Int
    let category: String
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
                    .lineLimit(1)
                
                Spacer()
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.top, 8)
            .lineLimit(1)
            .truncationMode(.tail)
            
            HStack {
                Spacer()
                
                if duration > 59 {
                    Text("\(duration / 60)" + NSLocalizedString("hour", comment: "hour") + " \(duration % 60)" + NSLocalizedString("min", comment: "min"))
                } else {
                    Text("\(duration) " + NSLocalizedString("mins", comment: "mins"))
                }
                
                Spacer()
                
                Text(category)
                
                Spacer()
            }
            .foregroundStyle(Color.textSecondary)
            .fontWeight(.regular)
            .padding(.bottom, 8)
        }
        .font(font)
        .background(Color.cardBg)
        .cornerRadius(8)
    }
}

