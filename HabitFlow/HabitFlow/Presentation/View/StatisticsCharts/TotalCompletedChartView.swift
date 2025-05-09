//
//  TotalCompletedChartView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI
import Charts

struct TotalCompletedChartView: View {
    @StateObject private var viewModel: StatisticsChartViewModel
    @State private var selectedPreset: PeriodPreset = .oneWeek
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("기간", selection: $selectedPreset) {
                    ForEach(PeriodPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .padding()
                .pickerStyle(.segmented)
                .onChange(of: selectedPreset) { newValue in
                    viewModel.updatePeriod(newValue.toPeriod())
                }
                
                TotalCompletedGraphView(viewModel: viewModel, selectedPreset: $selectedPreset)
                    .padding()
                
                VStack {
                    VStack(alignment: .leading) {
                        ChangeStatsView(viewModel: viewModel, selectedPreset: $selectedPreset)
                            .padding(.top, 16)
                        
                        AverageStatsView(selectedPreset: $selectedPreset, weekly: viewModel.calculateAverage(for: .oneWeek), monthly: viewModel.calculateAverage(for: .oneMonth))
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.25)
                    .background(Color.cardBg)
                    .cornerRadius(16)
                    .padding()
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5)
                .background(Color(.systemGroupedBackground))
            }
            .padding()
        }
        .navigationTitle(String(localized: "completed_habits"))
        .onAppear {
            viewModel.loadCompletedStats()
        }
    }
}

private struct TotalCompletedGraphView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    @Binding var selectedPreset: PeriodPreset
    
    var body: some View {
        Chart {
            ForEach(viewModel.completedStats, id: \.self) { stat in
                BarMark(
                    x: .value("날짜", stat.date, unit: .day),
                    y: .value("완료 수", stat.count)
                )
                .foregroundStyle(by: .value("카테고리", stat.title))
            }
        }
        .chartForegroundStyleScale([
            HabitCategory.healthyIt.title : HabitCategory.healthyIt.color,
            HabitCategory.canDoIt.title : HabitCategory.canDoIt.color,
            HabitCategory.moneyIt.title : HabitCategory.moneyIt.color,
            HabitCategory.greenIt.title : HabitCategory.greenIt.color,
            HabitCategory.myMindIt.title : HabitCategory.myMindIt.color
        ])
        .frame(height: 300)
        .chartXAxis {
            switch selectedPreset {
            case .oneWeek:
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
                
            case .oneMonth:
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
        }
        .chartYAxis {
            AxisMarks()
        }
        .onAppear {
            viewModel.updatePeriod(selectedPreset.toPeriod())
        }
    }
}

private struct ChangeStatsView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    @Binding var selectedPreset: PeriodPreset
    
    var body: some View {
        let weeklyAnalysis = viewModel.generateWeeklyAnalysis()
        let monthlyAnalysis = viewModel.generateMonthlyAnalysis()
        
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.calculateAverage(for: .oneWeek) == 0 {
                Text(NSLocalizedString("not_enough_record", comment: "not_enough_record"))
                    .foregroundStyle(Color.textSecondary)
            } else {
                HStack(spacing: 0) {
                    Text("\(selectedPreset.title)")
                    Text(NSLocalizedString("analyzed_noitce", comment: "analyzed_noitce"))
                }
                .font(.headline)
                
                switch selectedPreset {
                case .oneWeek:
                    VStack(alignment: .leading) {
                        Text(String(format: NSLocalizedString("last_period_notice", comment: ""), weeklyAnalysis[1]))
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        
                        Text(weeklyAnalysis[2])
                            .padding(.vertical, 4)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(weeklyAnalysis[3])
                            .padding(.bottom, 4)
                        
                    }
                    .onAppear{
                        viewModel.loadCompletedStats()
                        viewModel.loadPreviousCompletedStats(for: .oneWeek)
                    }
                    
                case .oneMonth:
                    VStack(alignment: .leading) {
                        Text(String(format: NSLocalizedString("last_period_notice", comment: ""), monthlyAnalysis[1]))
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        
                        Text(monthlyAnalysis[2])
                            .padding(.vertical, 4)
                        
                        Text(monthlyAnalysis[3])
                            .padding(.bottom, 4)
                        
                    }
                    .onAppear{
                        viewModel.loadPreviousCompletedStats(for: .oneMonth)
                    }
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
}

private struct AverageStatsView: View {
    @Binding var selectedPreset: PeriodPreset
    
    let weekly: Double
    let monthly: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if weekly != 0 || monthly != 0 {
                switch selectedPreset {
                case .oneWeek:
                    Text(String(format: NSLocalizedString("avg_notice", comment: ""), weekly))
                case .oneMonth:
                    Text(String(format: NSLocalizedString("avg_notice", comment: ""), monthly))
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
}
