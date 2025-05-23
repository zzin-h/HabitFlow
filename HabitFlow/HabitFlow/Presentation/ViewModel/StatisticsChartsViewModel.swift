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
    @Published var previousCompletedStats: [TotalCompletedStat] = []
    @Published var completedStats: [TotalCompletedStat] = []
    @Published var selectedPeriod: Period = .range(start: Date(), end: Date())
    @Published var groupedCompletionSummary: [(HabitCategory, [TotalCompletedStat])] = []
    
    @Published var activeDaysStat: ActiveDaysStat?
    @Published var completedDates: [Date] = []
    @Published var currentMonth: Date = Date()
    @Published var days: [DayCell] = []
    
    @Published var categoryStats: [HabitCategory: Int] = [:]
    @Published var categoryStatList: [CategoryStat] = []
    
    @Published var selectedCategory: HabitCategory = .healthyIt
    @Published var bestHabitStatsByCategory: [HabitCategory: [BestHabitStat]] = [:]
    @Published var top3Habits: [BestHabitStat] = []
    
    @Published var totalTimeStats: [TotalTimeStat] = []
    @Published var top3DurationHabits: [TotalTimeStat] = []
    
    @Published var weekdayStats: [WeekdayStat] = []
    @Published var timeSlotStats: [TimeSlotStat] = []
    @Published var top3Weekdays: [WeekdayStat] = []
    @Published var top3TimeSlots: [TimeSlotStat] = []
    
    @Published var routineSummary: RoutineSummary?
    @Published var isTodayMonday: Bool = false
    
    @Published var errorMessage: String?
    
    // MARK: - UseCase
    private let useCase: StatisticsChartsUseCase
    
    private let categoryDisplayOrder: [HabitCategory] = [
        .healthyIt,
        .canDoIt,
        .moneyIt,
        .greenIt,
        .myMindIt
    ]
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        useCase: StatisticsChartsUseCase
    ) {
        self.useCase = useCase
    }
    
    // MARK: - TotalCompleted
    func loadPreviousCompletedStats(for periodType: PeriodType) {
        useCase.fetchTotalCompletedStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                
                let calendar = self.calendar
                let now = Date()
                var startDate: Date
                var endDate: Date
                
                switch periodType {
                case .oneWeek:
                    let endOfLastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
                    let startOfLastWeek = calendar.date(byAdding: .day, value: -13, to: now)!
                    startDate = calendar.startOfDay(for: startOfLastWeek)
                    endDate = calendar.startOfDay(for: endOfLastWeek)
                    
                case .oneMonth:
                    let today = calendar.startOfDay(for: now)
                    let endOfLast30Days = calendar.date(byAdding: .day, value: -30, to: today)!
                    let startOfLast30Days = calendar.date(byAdding: .day, value: -59, to: today)!
                    
                    startDate = startOfLast30Days
                    endDate = endOfLast30Days
                }
                
                let dateList = self.generateDateList(from: startDate...endDate)
                
                let statsByDateAndCategory = Dictionary(grouping: stats) { stat in
                    DateCategoryKey(date: calendar.startOfDay(for: stat.date), category: stat.category)
                }
                
                var filledStats: [TotalCompletedStat] = []
                
                for date in dateList {
                    for category in HabitCategory.allCases {
                        let key = DateCategoryKey(date: date, category: category)
                        let items = statsByDateAndCategory[key] ?? []
                        let count = items.reduce(0) { $0 + $1.count }
                        let title = category.title
                        
                        let stat = TotalCompletedStat(
                            date: date,
                            title: title,
                            category: category,
                            count: count
                        )
                        
                        filledStats.append(stat)
                    }
                }
                
                self.previousCompletedStats = filledStats
            }
            .store(in: &cancellables)
    }
    
    func loadCompletedStats() {
        useCase.fetchTotalCompletedStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                let range = self.selectedPeriod.dateRange
                let dateList = self.generateDateList(from: range)
                
                let statsByDateAndCategory = Dictionary(grouping: stats) { stat in
                    DateCategoryKey(date: self.calendar.startOfDay(for: stat.date), category: stat.category)
                }
                
                var filledStats: [TotalCompletedStat] = []
                
                for date in dateList {
                    for category in HabitCategory.allCases {
                        let key = DateCategoryKey(date: date, category: category)
                        let items = statsByDateAndCategory[key] ?? []
                        let count = items.reduce(0) { $0 + $1.count }
                        let title = category.title
                        
                        let stat = TotalCompletedStat(
                            date: date,
                            title: title,
                            category: category,
                            count: count
                        )
                        
                        filledStats.append(stat)
                    }
                }
                
                self.completedStats = filledStats
            }
            .store(in: &cancellables)
    }
    
    func updatePeriod(_ period: Period) {
        selectedPeriod = period
        loadCompletedStats()
    }
    
    func calculateAverage(for preset: PeriodPreset) -> Double {
        let range = preset.toPeriod().dateRange
        let filtered = completedStats.filter { range.contains($0.date) }
        let totalCount = filtered.map(\.count).reduce(0, +)
        
        let activeDays = Set(filtered.map { Calendar.current.startOfDay(for: $0.date) })
        let activeDayCount = max(activeDays.count, 1)
        
        return Double(totalCount) / Double(activeDayCount)
    }
    
    func weeklyChangeDateRangeString() -> [String] {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfCurrentWeek = calendar.date(byAdding: .day, value: -6, to: now)!
        let endOfCurrentWeek = now
        
        let endOfLastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
        let startOfLastWeek = calendar.date(byAdding: .day, value: -13, to: now)!
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        
        let currentRange = "\(formatter.string(from: startOfCurrentWeek)) - \(formatter.string(from: endOfCurrentWeek))"
        let lastRange = "\(formatter.string(from: startOfLastWeek)) - \(formatter.string(from: endOfLastWeek))"
        
        return ["\(currentRange)", "\(lastRange)"]
    }
    
    func generateWeeklyAnalysis() -> [String] {
        let weekly = calculateChangeFromPrevious(current: completedStats, previous: previousCompletedStats)
        
        let rangeInfo = weeklyChangeDateRangeString()
        
        var analysis: [String] = rangeInfo
        
        if weekly.isSame {
            analysis += [NSLocalizedString("analysis_same_1", comment: ""),
                         NSLocalizedString("analysis_same_2", comment: "")]
        } else if weekly.isIncreased {
            if weekly.difference >= 5 {
                analysis += [String(format: NSLocalizedString("analysis_up_big_1", comment: ""), weekly.difference),
                             String(format: NSLocalizedString("analysis_up_big_2", comment: ""), weekly.percentage)]
            } else {
                analysis += [NSLocalizedString("analysis_up_small_1", comment: ""),
                             String(format: NSLocalizedString("analysis_up_small_2", comment: ""), weekly.difference)]
            }
        } else {
            if weekly.difference >= 5 {
                analysis += [String(format: NSLocalizedString("analysis_down_big_1", comment: ""), weekly.difference),
                             NSLocalizedString("analysis_down_big_2", comment: "")]
            } else {
                analysis += [NSLocalizedString("analysis_down_small_1", comment: ""),
                             String(format: NSLocalizedString("analysis_down_small_2", comment: ""), weekly.percentage)]
            }
        }
        
        return analysis
    }
    
    func monthlyChangeDateRangeString() -> [String] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let endOfLast30Days = calendar.date(byAdding: .day, value: -30, to: today)!
        let startOfLast30Days = calendar.date(byAdding: .day, value: -59, to: today)!
        
        let startOfThis30Days = calendar.date(byAdding: .day, value: -29, to: today)!
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        
        let thisMonthRange = "\(formatter.string(from: startOfThis30Days)) - \(formatter.string(from: today))"
        let lastMonthRange = "\(formatter.string(from: startOfLast30Days)) - \(formatter.string(from: endOfLast30Days))"
        
        return ["\(thisMonthRange)", "\(lastMonthRange)"]
    }
    
    func generateMonthlyAnalysis() -> [String] {
        let monthly = calculateChangeFromPrevious(current: completedStats, previous: previousCompletedStats)
        
        let rangeInfo = monthlyChangeDateRangeString()
        
        var analysis: [String] = rangeInfo
        
        if monthly.isSame {
            analysis += [NSLocalizedString("monthly_same_1", comment: ""),
                         NSLocalizedString("monthly_same_2", comment: "")]
        } else if monthly.isIncreased {
            if monthly.difference >= 15 {
                analysis += [String(format: NSLocalizedString("monthly_increase_high_1", comment: ""), monthly.difference),
                             String(format: NSLocalizedString("monthly_increase_high_2", comment: ""), monthly.percentage)]
            } else {
                analysis += [NSLocalizedString("monthly_increase_low_1", comment: ""),
                             String(format: NSLocalizedString("monthly_increase_low_2", comment: ""), monthly.difference)]
            }
        } else {
            if monthly.difference >= 15 {
                analysis += [String(format: NSLocalizedString("monthly_decrease_high_1", comment: ""), monthly.difference),
                             NSLocalizedString("monthly_decrease_high_2", comment: "")]
            } else {
                analysis += [NSLocalizedString("monthly_decrease_low_1", comment: ""),
                             String(format: NSLocalizedString("monthly_decrease_low_2", comment: ""), monthly.percentage)]
            }
        }
        
        return analysis
    }
    
    // MARK: - ActiveDays
    func loadActiveDaysStat() {
        useCase.fetchActiveDaysStat()
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
        useCase.fetchCompletedDates()
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
        useCase.fetchCompletedDates()
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
    
    // MARK: - FavoriteCategory
    func loadAllCategoryStats() {
        useCase.fetchCategoryStats()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                
                self.categoryStats = Dictionary(
                    uniqueKeysWithValues: stats.map { ($0.category, $0.totalCount) }
                )
                
                self.categoryStatList = self.categoryDisplayOrder.compactMap { category in
                    guard let stat = stats.first(where: { $0.category == category }) else { return nil }
                    return stat.totalCount > 0 ? stat : nil
                }
            }
            .store(in: &cancellables)
    }
    
    func makePieSlices() -> [PieSlice] {
        let total = categoryStatList.map { $0.totalCount }.reduce(0, +)
        var slices: [PieSlice] = []
        var startAngle = 0.0
        
        for stat in categoryStatList {
            let percentage = Double(stat.totalCount) / Double(total)
            let endAngle = startAngle + percentage * 360
            
            let slice = PieSlice(
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle),
                color: stat.color,
                title: stat.title,
                value: Double(stat.totalCount),
                percentage: percentage
            )
            
            slices.append(slice)
            startAngle = endAngle
        }
        
        return slices
    }
    
    // MARK: - BestHabit
    func loadAllBestHabits() {
        useCase.fetchBestHabitsWithCategory()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] habitDict in
                guard let self = self else { return }
                
                let stats: [BestHabitStat] = habitDict.map { title, value in
                    BestHabitStat(title: title, count: value.count, category: value.category)
                }
                
                let groupedByCategory = Dictionary(grouping: stats, by: \.category)
                self.bestHabitStatsByCategory = groupedByCategory
                
                let allStats = stats
                self.top3Habits = allStats.sorted { $0.count > $1.count }.prefix(3).map { $0 }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - TotalTime
    func loadTotalTimeStats() {
        useCase.fetchTotalTimeStat()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                
                self.totalTimeStats = stats.filter { $0.duration > 0 }
                
                self.top3DurationHabits = self.totalTimeStats
                    .sorted { $0.duration > $1.duration }
                    .prefix(3)
                    .map { $0 }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - TimePattern
    func loadTimePatternStats() {
        useCase.fetchTimePatternStat()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }
                
                self.weekdayStats = stats.weekdayStats
                self.timeSlotStats = stats.timeSlotStats
                
                self.top3Weekdays = self.weekdayStats
                    .sorted { $0.count > $1.count }
                    .prefix(3)
                    .map { $0 }
                self.top3TimeSlots = self.timeSlotStats
                    .sorted { $0.count > $1.count }
                    .prefix(3)
                    .map { $0 }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Summary
    func loadSummary(for period: Period) {
        useCase.fetchSummary()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] summaryTexts in
                guard let self = self else { return }
                
                self.routineSummary = summaryTexts
            }
            .store(in: &cancellables)
    }
    
    func checkIfTodayIsWeeklySummaryDay() {
        let today = Date()
        isTodayMonday = calendar.component(.weekday, from: today) == 2
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
    
    var filteredHabits: [BestHabitStat] {
        bestHabitStatsByCategory[selectedCategory] ?? []
    }
    
    var filteredTotalTimeStats: [TotalTimeStat] {
        totalTimeStats.filter { $0.category == selectedCategory }
    }
    
    private func generateDateList(from range: ClosedRange<Date>) -> [Date] {
        var dates: [Date] = []
        var current = calendar.startOfDay(for: range.lowerBound)
        let end = calendar.startOfDay(for: range.upperBound)
        
        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        return dates
    }
    
    private func calculateChangeFromPrevious(current: [TotalCompletedStat], previous: [TotalCompletedStat]) -> ChangeStat {
        let currentCount = current.map(\.count).reduce(0, +)
        let previousCount = previous.map(\.count).reduce(0, +)
        
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
            difference: difference,
            percentage: Double(abs(percentage))
        )
    }
}
