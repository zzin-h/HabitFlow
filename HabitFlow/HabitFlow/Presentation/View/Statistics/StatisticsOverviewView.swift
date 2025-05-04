//
//  StatisticsOverviewView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct StatisticsOverviewView: View {
    @StateObject private var viewModel: StatisticsViewModel
    @StateObject private var chartViewModel: StatisticsChartViewModel
    @State private var selectedDetailType: StatisticsDetailType?
    
    init(viewModel: StatisticsViewModel = StatisticsDIContainer().makeStatisticsViewModel(),
         chartViewModel: StatisticsChartViewModel = StatisticsChartsDIContainer().makeStatisticsChartViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _chartViewModel = StateObject(wrappedValue: chartViewModel)
    }
    
    let columns = Array(repeating: GridItem(.flexible(minimum: 100, maximum: 200)), count: 2)
    
    var body: some View {
        ScrollView {
            if chartViewModel.isTodayMonday {
                RoutineSummaryView(lastweek: lastWeekDateRange)
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                StatisticsCardView(
                    title: "완료한 습관",
                    icon: "checkmark.circle.fill",
                    value: ["총 \(viewModel.totalCompletedCount)회"],
                    color: HabitCategory.healthyIt.color,
                    actionView: .totalCompleted
                )
                
                StatisticsCardView(
                    title: "함께한 일수",
                    icon: "calendar.circle.fill",
                    value: ["총 \(viewModel.activeDays)일", "연속 \(viewModel.streakDays)일"],
                    color: HabitCategory.canDoIt.color,
                    actionView: .activeDays
                )
                
                StatisticsCardView(
                    title: "관심 카테고리",
                    icon: "tag.circle.fill",
                    value: [convertToKorean(category: viewModel.favoriteCategory)],
                    color: HabitCategory.moneyIt.color,
                    actionView: .favoriteCategory
                )
                
                StatisticsCardView(
                    title: "베스트 습관",
                    icon: "star.circle.fill",
                    value: [viewModel.bestHabitTitle],
                    color: HabitCategory.greenIt.color,
                    actionView: .bestHabits
                )
                
                StatisticsCardView(
                    title: "함께한 시간",
                    icon: "clock.fill",
                    value: ["총 \(viewModel.totalTimeSpent / 60)시간 \(viewModel.totalTimeSpent % 60)분"],
                    color: HabitCategory.myMindIt.color,
                    actionView: .totalTime
                )
                
                StatisticsCardView(
                    title: "최다 요일 및 시간대",
                    icon: "hand.thumbsup.circle.fill",
                    value: ["\(viewModel.mostFrequentDay)", "\(viewModel.mostFrequentTime)"],
                    color: .indigo,
                    actionView: .timeBasedStats
                )
            }
            .padding()
            
            if !chartViewModel.isTodayMonday {
                NavigationLink(destination: RoutineSummaryView(lastweek: lastWeekDateRange)) {
                    HStack(alignment: .center) {
                        Image(systemName: "lightbulb.circle.fill")
                            .foregroundStyle(Color(red: 239/255, green: 136/255, blue: 173/255))
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading) {
                            Text("주간 리포트")
                                .font(.headline)
                                .foregroundStyle(Color.textPrimary)
                            
                            Text(lastWeekDateRange)
                                .font(.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cardBg)
                    .cornerRadius(12)
                }
                .padding()
            }
            
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("습관 요약")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadStatistics()
            checkIfTodayNeedsSummaryUpdate()
            
        }
    }
    
    private func convertToKorean(category: String) -> String {
        switch category {
        case "healthyIt":
            return "헬시잇"
        case "canDoIt":
            return "할수잇"
        case "moneyIt":
            return "머니잇"
        case "greenIt":
            return "그린잇"
        case "myMindIt":
            return "내맘잇"
        default:
            return "없음"
        }
    }
    
    private func checkIfTodayNeedsSummaryUpdate() {
        let today = Date()
        let calendar = Calendar.current
        
        let isMonday = calendar.component(.weekday, from: today) == 2
        
        if isMonday {
            let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today)!
            let period = Period.weekly(lastWeek)
            chartViewModel.loadSummary(for: period)
        }
    }
    
    private var lastWeekDateRange: String {
        let calendar = Calendar.current
        let now = Date()
        
        let endOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
        let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -2, to: now)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        
        let lastRange = "\(formatter.string(from: startOfLastWeek)) ~ \(formatter.string(from: endOfLastWeek))"
        
        return lastRange
    }
}
