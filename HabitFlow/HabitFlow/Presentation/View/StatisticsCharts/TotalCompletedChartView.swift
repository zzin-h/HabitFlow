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
    @State private var selectedStat: TotalCompletedStat?
    
    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("기간", selection: $selectedPreset) {
                    ForEach(PeriodPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedPreset) { newValue in
                    viewModel.updatePeriod(newValue.toPeriod())
                }
                
                if viewModel.completedStats.isEmpty {
                    Text("데이터가 없습니다.")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                } else {
                    TotalCompletedGraphView(viewModel: viewModel, selectedStat: $selectedStat, selectedPreset: $selectedPreset)
                }
                
                AverageStatsView(selectedPreset: $selectedPreset, weekly: viewModel.calculateAverage(for: .oneWeek), monthly: viewModel.calculateAverage(for: .oneMonth))
                
                ChangeStatsView(viewModel: viewModel, selectedPreset: $selectedPreset)
            }
            .padding()
        }
        .navigationTitle("완료한 습관")
        .onAppear {
            viewModel.loadCompletedStats()
        }
    }
}

private struct TotalCompletedGraphView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    @Binding var selectedStat: TotalCompletedStat?
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

private struct AverageStatsView: View {
    @Binding var selectedPreset: PeriodPreset
    
    let weekly: Double
    let monthly: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📊 평균 완료 개수")
                .font(.headline)
            
            switch selectedPreset {
            case .oneWeek:
                Text("이번 주 하루 평균 \(String(format: "%.1f", weekly))회 완료했어요.")
            case .oneMonth:
                Text("이번 달 하루 평균 \(String(format: "%.1f", monthly))회 완료했어요.")
            }
        }
        .font(.subheadline)
    }
}

private struct ChangeStatsView: View {
    @ObservedObject var viewModel: StatisticsChartViewModel
    @Binding var selectedPreset: PeriodPreset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📈 수행 변화량")
                .font(.headline)
            
            switch selectedPreset {
            case .oneWeek:
                ForEach(viewModel.generateWeeklyAnalysis(), id: \.self) { line in
                    Text(line)
                }
                .onAppear{
                    viewModel.loadPreviousCompletedStats(for: .oneWeek)
                }
                
            case .oneMonth:
                ForEach(viewModel.generateMonthlyAnalysis(), id: \.self) { line in
                    Text(line)
                }
                .onAppear{
                    viewModel.loadPreviousCompletedStats(for: .oneMonth)
                }
            }
            
        }
        .font(.subheadline)
    }
}

