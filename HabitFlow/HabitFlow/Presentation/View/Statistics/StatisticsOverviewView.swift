//
//  StatisticsOverviewView.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import SwiftUI

struct StatisticsOverviewView: View {
    @StateObject private var viewModel: StatisticsViewModel
    @State private var selectedDetailType: StatisticsDetailType?
    
    init(viewModel: StatisticsViewModel = StatisticsDIContainer().makeStatisticsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    NavigationLink(destination: TotalCompletedChartView()) {
                        Text("total completed")
                    }
                    
                    NavigationLink(destination: ActiveDaysChartView()) {
                        Text("ActiveDays")
                    }
                    
                    NavigationLink(destination: FavoriteCategoryChartView()) {
                        Text("FavoriteCategory")
                    }
                    
                    NavigationLink(destination: BestHabitChartView()) {
                        Text("BestHabit")
                    }
                    
                    NavigationLink(destination: TotalTimeChartView()) {
                        Text("TotalTime")
                    }
                    
                    StatisticsCardView(
                        title: "완료한 습관",
                        icon: "checkmark.circle.fill",
                        value: "\(viewModel.totalCompletedCount)",
                        color: .blue
                    ) {
                        selectedDetailType = .totalCompleted
                    }
                    
                    StatisticsCardView(
                        title: "함께한 일수",
                        icon: "calendar.circle.fill",
                        value: "총 \(viewModel.activeDays)일 · 연속 \(viewModel.streakDays)일",
                        color: .orange
                    ) {
                        selectedDetailType = .activeDays
                    }
                    
                    StatisticsCardView(
                        title: "관심 카테고리",
                        icon: "tag.circle.fill",
                        value: convertToKorean(category: viewModel.favoriteCategory),
                        color: .green
                    ) {
                        selectedDetailType = .favoriteCategory
                    }
                    
                    StatisticsCardView(
                        title: "베스트 습관",
                        icon: "star.circle.fill",
                        value: viewModel.bestHabitTitle,
                        color: .purple
                    ) {
                        selectedDetailType = .bestHabits
                    }
                    
                    StatisticsCardView(
                        title: "총 시간",
                        icon: "clock.fill",
                        value: "\(viewModel.totalTimeSpent)분",
                        color: .pink
                    ) {
                        selectedDetailType = .totalTime
                    }
                    
                    StatisticsCardView(
                        title: "날짜 기반 통계",
                        icon: "calendar.circle.fill",
                        value: "가장 자주 수행한 요일: \(viewModel.mostFrequentDay) · 시간대: \(viewModel.mostFrequentTime)",
                        color: .cyan
                    ) {
                        selectedDetailType = .timeBasedStats
                    }
                }
                .padding()
            }
            .navigationTitle("나의 통계")
            //            .navigationDestination(item: $selectedDetailType) { type in
            //                StatisticsDetailRouter.view(for: type, viewModel: viewModel)
            //            }
            .onAppear {
                viewModel.loadStatistics()
            }
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
}
