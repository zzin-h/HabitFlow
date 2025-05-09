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
                    title: String(localized: "completed_habits"),
                    icon: "checkmark.circle.fill",
                    value: [String(localized: "total") + " \(viewModel.totalCompletedCount)" + String(localized: "times")],
                    color: HabitCategory.healthyIt.color,
                    actionView: .totalCompleted
                )
                
                StatisticsCardView(
                    title: String(localized: "active_days"),
                    icon: "calendar.circle.fill",
                    value: [String(localized: "total") + " \(viewModel.activeDays)" + String(localized: "days"),
                            String(localized: "consecutive") + "\(viewModel.streakDays)" + String(localized: "consecutive_days")],
                    color: HabitCategory.canDoIt.color,
                    actionView: .activeDays
                )
                
                StatisticsCardView(
                    title: String(localized: "favorite_category"),
                    icon: "tag.circle.fill",
                    value: [convertToLocal(category: viewModel.favoriteCategory)],
                    color: HabitCategory.moneyIt.color,
                    actionView: .favoriteCategory
                )
                
                StatisticsCardView(
                    title: String(localized: "best_habit"),
                    icon: "star.circle.fill",
                    value: [viewModel.bestHabitTitle],
                    color: HabitCategory.greenIt.color,
                    actionView: .bestHabits
                )
                
                StatisticsCardView(
                    title: String(localized: "total_time"),
                    icon: "clock.fill",
                    value: [String(localized: "total") + " \(viewModel.totalTimeSpent / 60)" + String(localized: "hour") + "  \(viewModel.totalTimeSpent % 60)" + String(localized: "min")],
                    color: HabitCategory.myMindIt.color,
                    actionView: .totalTime
                )
                
                StatisticsCardView(
                    title: String(localized: "most_frequent"),
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
                            Text(NSLocalizedString("weekly_report", comment: "weekly_report"))
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
        .navigationTitle(String(localized: "statistics_nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadStatistics()
            chartViewModel.checkIfTodayIsWeeklySummaryDay()
            checkIfTodayNeedsSummaryUpdate()
            
        }
    }
    
    private func convertToLocal(category: String) -> String {
        switch category {
        case "healthyIt": return String(localized: "healthyIt")
        case "canDoIt": return String(localized: "canDoIt")
        case "moneyIt": return String(localized: "moneyIt")
        case "greenIt": return String(localized: "greenIt")
        case "myMindIt": return String(localized: "myMindIt")
        default: return ""
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
        
        let weekday = calendar.component(.weekday, from: now)
        let daysSinceMonday = (weekday + 5) % 7
        let thisMonday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: calendar.startOfDay(for: now))!
        let lastMonday = calendar.date(byAdding: .day, value: -7, to: thisMonday)!
        let lastSunday = calendar.date(byAdding: .day, value: 6, to: lastMonday)!
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        
        return "\(formatter.string(from: lastMonday)) - \(formatter.string(from: lastSunday))"
    }
}
