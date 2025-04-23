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
    @State private var selectedPreset: PeriodPreset = .thisWeek
    @State private var selectedStat: TotalCompletedStat?
    @State private var chartFrame: CGRect = .zero

    init(viewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("총 완료 통계")
                .font(.title2)
                .bold()

            // 기간 선택
            Picker("기간", selection: $selectedPreset) {
                ForEach(PeriodPreset.allCases) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)

            if viewModel.completedStats.isEmpty {
                Text("데이터가 없습니다.")
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(viewModel.completedStats, id: \.self) { stat in
                        BarMark(
                            x: .value("날짜", stat.date, unit: .day),
                            y: .value("완료 수", stat.count)
                        )
                        .foregroundStyle(by: .value("카테고리", stat.category.title))
                        .annotation(position: .top, alignment: .center, spacing: 4) {
                            if selectedStat == stat {
                                Text("\(stat.category.title): \(stat.count)")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color(.systemBackground).opacity(0.8))
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(Color.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let location = value.location
                                        chartFrame = geo.frame(in: .local)

                                        if let date: Date = proxy.value(atX: location.x) {
                                            let nearest = viewModel.completedStats
                                                .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                                                .first

                                            selectedStat = nearest
                                        }
                                    }
                                    .onEnded { _ in
                                         selectedStat = nil
                                    }
                            )
                    }
                }
                .frame(height: 300)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks()
                }
                .frame(height: 300)
            }
        }
        .padding()
        
        if !viewModel.todayCompletedByCategory.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("📌 오늘의 완료 습관")
                    .font(.headline)
                    .padding(.bottom, 2)

                ForEach(Array(viewModel.todayCompletedByCategory.keys), id: \.self) { category in
                    if let titles = viewModel.todayCompletedByCategory[category] {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("• \(category.title)")
                                .bold()
                                .font(.subheadline)
                            Text(titles.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("📊 평균 완료 개수")
                .font(.headline)

            Text("이번 주: 하루 평균 \(String(format: "%.1f", viewModel.weeklyAverage))회 완료했어요.")
            Text("이번 달: 하루 평균 \(String(format: "%.1f", viewModel.monthlyAverage))회 완료했어요.")
        }
        .font(.subheadline)
        .padding(.top)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("📈 수행 변화량")
                .font(.headline)

            if let weekly = viewModel.weeklyChange {
                if weekly.isSame {
                    Text("지난주와 비교했을 때 완료한 습관이 같아요! 루틴이 잡혀가고 있다는 좋은 징조예요! 👏")
                } else {
                    Text("지난주 대비 총 \(weekly.difference)개 \(weekly.isIncreased ? "늘었어요" : "줄었어요").")
                    Text("지난주 대비 \(String(format: "%.1f", weekly.percentage))% 수행력이 \(weekly.isIncreased ? "향상되었어요" : "약화되었어요").")
                }
            }

            if let monthly = viewModel.monthlyChange {
                if monthly.isSame {
                    Text("지난달과 비교했을 때 완료한 습관이 같아요! 안정적인 루틴이 유지되고 있어요 😊")
                } else {
                    Text("지난달 대비 총 \(monthly.difference)개 \(monthly.isIncreased ? "늘었어요" : "줄었어요").")
                    Text("지난달 대비 \(String(format: "%.1f", monthly.percentage))% 수행력이 \(monthly.isIncreased ? "향상되었어요" : "약화되었어요").")
                }
            }
        }
        .font(.subheadline)
        .padding(.top)
        
        .onAppear {
            viewModel.loadCompletedStats()
        }
        .onChange(of: selectedPreset) { newValue in
            viewModel.updatePeriod(newValue.toPeriod())
        }
    }
}

struct StatisticsPeriodPickerView: View {
    @Binding var selectedPeriod: Period
    @State private var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var customEndDate: Date = Date()
    @State private var showCustomPicker: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("기간 선택", selection: $selectedPeriod) {
                Text("일간").tag(Period.daily(Date()))
                Text("주간").tag(Period.weekly(Date()))
                Text("월간").tag(Period.monthly(year: Calendar.current.component(.year, from: Date()), month: Calendar.current.component(.month, from: Date())))
                Text("커스텀").tag(Period.custom(start: customStartDate, end: customEndDate))
            }
            .pickerStyle(.segmented)

            if case .custom = selectedPeriod {
                VStack(spacing: 8) {
                    DatePicker("시작일", selection: $customStartDate, displayedComponents: .date)
                    DatePicker("종료일", selection: $customEndDate, displayedComponents: .date)

                    Button("적용") {
                        selectedPeriod = .custom(start: customStartDate, end: customEndDate)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 8)
            }
        }
        .animation(.easeInOut, value: selectedPeriod)
    }
}
