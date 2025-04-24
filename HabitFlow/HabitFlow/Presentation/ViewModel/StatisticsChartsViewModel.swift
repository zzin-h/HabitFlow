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
    @Published var selectedPeriod: Period = .range(start: Date(), end: Date())
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
    
    func generateWeeklyAnalysis() -> [String] {
        guard let weekly = weeklyChange else { return [] }
        
        if weekly.isSame {
            return ["지난주와 똑같은 횟수로 루틴을 지켰어요.", "루틴이 안정적으로 유지되고 있어요 😊"]
        } else if weekly.isIncreased {
            if weekly.difference >= 5 {
                return ["와! 지난주보다 \(weekly.difference)개나 더 완료했어요! 🔥",
                        "\(String(format: "%.1f", weekly.percentage))% 상승했어요. 점점 좋아지고 있어요!"]
            } else {
                return ["조금씩 성장 중이에요 💪",
                        "지난주보다 \(weekly.difference)개 더 했어요. 꾸준함이 중요하니까요!"]
            }
        } else {
            if weekly.difference >= 5 {
                return ["지난주보다 \(weekly.difference)개 줄었어요. 요즘 좀 바빴던 건 아닐까요?",
                        "잠깐 쉬어가는 것도 괜찮아요. 다음 주엔 다시 도전해봐요 💛"]
            } else {
                return ["지난주보다 조금 줄었지만, 괜찮아요. 다시 리듬을 찾으면 돼요 🍀",
                        "\(String(format: "%.1f", weekly.percentage))% 감소했어요."]
            }
        }
    }
    
    func generateMonthlyAnalysis() -> [String] {
        guard let monthly = monthlyChange else { return [] }

        if monthly.isSame {
            return ["지난달과 같은 루틴 수행량이에요.",
                    "꾸준함이 가장 어려운데, 정말 잘하고 있어요! 👏"]
        } else if monthly.isIncreased {
            if monthly.difference >= 15 {
                return ["지난달보다 \(monthly.difference)개 더 완료했어요! 😍",
                        "\(String(format: "%.1f", monthly.percentage))% 상승했어요. 눈에 띄는 성장입니다!"]
            } else {
                return ["조금 더 노력한 한 달이었어요! 👍",
                        "\(monthly.difference)개 늘었어요. 멋져요!"]
            }
        } else {
            if monthly.difference >= 15 {
                return ["지난달보다 \(monthly.difference)개 줄었어요.",
                        "컨디션이 좋지 않았던 걸 수도 있어요. 다음 달엔 다시 회복할 수 있어요 💪"]
            } else {
                return ["루틴 수행이 살짝 줄었어요.",
                        "\(String(format: "%.1f", monthly.percentage))% 감소했어요. 괜찮아요, 다시 시작해봐요! 🌱"]
            }
        }
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
    
    var weeklyChange: ChangeStat? {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfCurrentWeek = calendar.date(byAdding: .day, value: -6, to: now)!
        let endOfCurrentWeek = now

        let endOfLastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
        let startOfLastWeek = calendar.date(byAdding: .day, value: -13, to: now)!

        let current = Period.range(start: startOfCurrentWeek, end: endOfCurrentWeek)
        let previous = Period.range(start: startOfLastWeek, end: endOfLastWeek)

        return calculateChange(current: current, previous: previous)
    }
    
    var monthlyChange: ChangeStat? {
        let calendar = Calendar.current
        let now = Date()

        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfCurrentMonth = now

        let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now)!
        let startOfLastMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonthDate))!
        let endOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfLastMonth)!

        let current = Period.range(start: startOfCurrentMonth, end: endOfCurrentMonth)
        let previous = Period.range(start: startOfLastMonth, end: endOfLastMonth)

        return calculateChange(current: current, previous: previous)
    }
    
    private func calculateChange(current: Period, previous: Period) -> ChangeStat? {
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
        
        return ChangeStat(
            isSame: isSame,
            isIncreased: isIncreased,
            difference: Int(percentage),
            percentage: abs(percentage)
        )
    }
}
