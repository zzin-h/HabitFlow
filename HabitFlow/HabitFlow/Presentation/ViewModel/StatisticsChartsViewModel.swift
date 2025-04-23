//
//  StatisticsChartsViewModel.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

final class StatisticsChartViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var completedStats: [TotalCompletedStat] = []
    @Published var selectedPeriod: Period = .weekly(Date())
    @Published var activeDaysStat: ActiveDaysStat?
    @Published var errorMessage: String?
    
    // MARK: - Use Cases
    private let fetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase
    private let fetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        fetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase,
        fetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase
    ) {
        self.fetchTotalCompletedStatsUseCase = fetchTotalCompletedStatsUseCase
        self.fetchActiveDaysStatUseCase = fetchActiveDaysStatUseCase
    }

    // MARK: - TotalCompleted
    func loadCompletedStats() {
        fetchTotalCompletedStatsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self else { return }
                let range = self.selectedPeriod.dateRange
                let filtered = stats.filter { range.contains($0.date) }
                self.completedStats = filtered
            }
            .store(in: &cancellables)
    }
    
    func updatePeriod(_ period: Period) {
        selectedPeriod = period
        loadCompletedStats()
    }
    
    // MARK: - ActiveDays
    func loadActiveDaysStat() {
        fetchActiveDaysStatUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stat in
                self?.activeDaysStat = stat
            }
            .store(in: &cancellables)
    }
}

// MARK: - extension
extension StatisticsChartViewModel {
    var todayCompletedByCategory: [HabitCategory: [String]] {
        let todayStats = completedStats.filter {
            Calendar.current.isDateInToday($0.date)
        }

        var result: [HabitCategory: [String]] = [:]
        for stat in todayStats {
            result[stat.category, default: []].append(stat.title)
        }
        return result
    }

    var weeklyAverage: Double {
        let range = Period.weekly(Date()).dateRange

        let filtered = completedStats.filter { range.contains($0.date) }
        let totalCount = filtered.map(\.count).reduce(0, +)

        let activeDays = Set(filtered.map { Calendar.current.startOfDay(for: $0.date) })
        let activeDayCount = max(activeDays.count, 1)

        return Double(totalCount) / Double(activeDayCount)
    }

    var monthlyAverage: Double {
        let now = Date()
        let range = Period.monthly(year: now.year, month: now.month).dateRange

        let filtered = completedStats.filter { range.contains($0.date) }
        let totalCount = filtered.map(\.count).reduce(0, +)

        let activeDays = Set(filtered.map { Calendar.current.startOfDay(for: $0.date) })
        let activeDayCount = max(activeDays.count, 1)

        return Double(totalCount) / Double(activeDayCount)
    }

    struct ChangeSummary {
        let difference: Int
        let percentage: Double
        let isIncreased: Bool
        let isSame: Bool
    }

    var weeklyChange: ChangeSummary? {
        calculateChange(
            current: Period.weekly(Date()),
            previous: Period.weekly(Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!)
        )
    }

    var monthlyChange: ChangeSummary? {
        let now = Date()
        let thisMonth = Period.monthly(year: now.year, month: now.month)
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        let lastMonth = Period.monthly(year: lastMonthDate.year, month: lastMonthDate.month)
        
        return calculateChange(current: thisMonth, previous: lastMonth)
    }

    private func calculateChange(current: Period, previous: Period) -> ChangeSummary? {
        let currentStats = completedStats.filter { current.dateRange.contains($0.date) }
        let previousStats = completedStats.filter { previous.dateRange.contains($0.date) }

        let currentCount = currentStats.map(\.count).reduce(0, +)
        let previousCount = previousStats.map(\.count).reduce(0, +)

        let difference = currentCount - previousCount
        let isSame = difference == 0
        let isIncreased = difference > 0
        let percentage: Double

        if previousCount == 0 {
            percentage = currentCount > 0 ? 100.0 : 0.0
        } else {
            percentage = (Double(difference) / Double(previousCount)) * 100
        }

        return ChangeSummary(
            difference: abs(difference),
            percentage: abs(percentage),
            isIncreased: isIncreased,
            isSame: isSame
        )
    }
}
