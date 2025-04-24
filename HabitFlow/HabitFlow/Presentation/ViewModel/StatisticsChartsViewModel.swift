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
    @Published var completedDates: [Date] = []
    @Published var currentMonth: Date = Date()
    @Published var days: [DayCell] = []
    @Published var errorMessage: String?
    
    // MARK: - Use Cases
    private let fetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase
    private let fetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase
    private let fetchCompletedDatesUseCase: FetchCompletedDatesUseCase
    
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        fetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase,
        fetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase,
        fetchCompletedDatesUseCase: FetchCompletedDatesUseCase
    ) {
        self.fetchTotalCompletedStatsUseCase = fetchTotalCompletedStatsUseCase
        self.fetchActiveDaysStatUseCase = fetchActiveDaysStatUseCase
        self.fetchCompletedDatesUseCase = fetchCompletedDatesUseCase
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
    
    func loadCompletedDates() {
        fetchCompletedDatesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dates in
                self?.completedDates = dates.sorted()
            }
            .store(in: &cancellables)
    }
    
    func generateDays(for month: Date, completedDates: Set<Date>) {
        var days: [DayCell] = []
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else { return }
        
        let startOffset = (firstWeekday - calendar.firstWeekday + 7) % 7
        var current = calendar.date(byAdding: .day, value: -startOffset, to: monthInterval.start)!
        
        while days.count < 42 {
            let isCompleted = completedDates.contains(calendar.startOfDay(for: current))
            let isInCurrentMonth = calendar.isDate(current, equalTo: month, toGranularity: .month)
            
            days.append(DayCell(
                date: current,
                isCompleted: isCompleted,
                isInCurrentMonth: isInCurrentMonth
            ))
            
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        if days.suffix(7).allSatisfy({ !$0.isInCurrentMonth }) {
            days.removeLast(7)
        }
        
        self.days = days
    }
    
    func previousMonth() {
        if let previous = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previous
            fetchAndGenerateDays()
        }
    }
    
    func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = next
            fetchAndGenerateDays()
        }
    }
    
    func fetchAndGenerateDays() {
        fetchCompletedDatesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] dates in
                guard let self = self else { return }
                self.completedDates = dates.map { Calendar.current.startOfDay(for: $0) }
                self.generateDays(for: self.currentMonth, completedDates: Set(self.completedDates))
            }
            .store(in: &cancellables)
    }

    func calculateMonthlyAchievement(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let daysInMonth = range.count
        let endOfMonth = calendar.date(byAdding: .day, value: daysInMonth - 1, to: startOfMonth)!
        let uniqueDates = Set(dates.map { calendar.startOfDay(for: $0) })
        let completedThisMonth = uniqueDates.filter { $0 >= startOfMonth && $0 <= endOfMonth }
        
        return Int((Double(completedThisMonth.count) / Double(daysInMonth)) * 100)
    }
    
    func longestBreakGap(from dates: [Date]) -> (start: Date, end: Date, days: Int)? {
        let calendar = Calendar.current
        let sortedDates = Set(dates.map { calendar.startOfDay(for: $0) }).sorted()

        guard sortedDates.count >= 2 else { return nil }

        var maxGap = 0
        var gapStartDate: Date = sortedDates[0]
        var gapEndDate: Date = sortedDates[1]

        for i in 0..<sortedDates.count - 1 {
            let current = sortedDates[i]
            let next = sortedDates[i + 1]
            let gap = calendar.dateComponents([.day], from: current, to: next).day ?? 0

            if gap > maxGap {
                maxGap = gap
                gapStartDate = current
                gapEndDate = next
            }
        }

        return (gapStartDate, gapEndDate, maxGap - 1)
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
