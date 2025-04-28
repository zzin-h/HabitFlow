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
    
    @Published var errorMessage: String?
    
    // MARK: - Use Cases
    private let fetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase
    private let fetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase
    private let fetchCompletedDatesUseCase: FetchCompletedDatesUseCase
    
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
        fetchTotalCompletedStatsUseCase: FetchTotalCompletedStatsUseCase,
        fetchActiveDaysStatUseCase: FetchActiveDaysStatUseCase,
        fetchCompletedDatesUseCase: FetchCompletedDatesUseCase
    ) {
        self.fetchTotalCompletedStatsUseCase = fetchTotalCompletedStatsUseCase
        self.fetchActiveDaysStatUseCase = fetchActiveDaysStatUseCase
        self.fetchCompletedDatesUseCase = fetchCompletedDatesUseCase
    }
    
    // MARK: - TotalCompleted
    func loadPreviousCompletedStats(for periodType: PeriodType) {
        fetchTotalCompletedStatsUseCase.execute()
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
                    let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
                    startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonth))!
                    endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate)!
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
        fetchTotalCompletedStatsUseCase.execute()
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
    
    func weeklyChangeDateRangeString() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfCurrentWeek = calendar.date(byAdding: .day, value: -6, to: now)!
        let endOfCurrentWeek = now
        
        let endOfLastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
        let startOfLastWeek = calendar.date(byAdding: .day, value: -13, to: now)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        
        let currentRange = "\(formatter.string(from: startOfCurrentWeek)) ~ \(formatter.string(from: endOfCurrentWeek))"
        let lastRange = "\(formatter.string(from: startOfLastWeek)) ~ \(formatter.string(from: endOfLastWeek))"
        
        return "이번 주: \(currentRange) | 지난 주: \(lastRange)"
    }
    
    func monthlyChangeDateRangeString() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        let startOfLastMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonth))!
        let endOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfLastMonth)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        
        let thisMonthRange = "\(formatter.string(from: startOfThisMonth)) ~ \(formatter.string(from: now))"
        let lastMonthRange = "\(formatter.string(from: startOfLastMonth)) ~ \(formatter.string(from: endOfLastMonth))"
        
        return "이번 달: \(thisMonthRange) | 지난 달: \(lastMonthRange)"
    }
    
    func generateWeeklyAnalysis() -> [String] {
        let weekly = calculateChangeFromPrevious(current: completedStats, previous: previousCompletedStats)
        
        let rangeInfo = weeklyChangeDateRangeString()
        
        var analysis: [String] = [rangeInfo]
        
        if weekly.isSame {
            analysis += ["지난주와 똑같은 횟수로 루틴을 지켰어요.", "루틴이 안정적으로 유지되고 있어요 😊"]
        } else if weekly.isIncreased {
            if weekly.difference >= 5 {
                analysis += ["와! 지난주보다 \(weekly.difference)개나 더 완료했어요! 🔥",
                             "\(String(format: "%.1f", weekly.percentage))% 상승했어요. 점점 좋아지고 있어요!"]
            } else {
                analysis += ["조금씩 성장 중이에요 💪",
                             "지난주보다 \(weekly.difference)개 더 했어요. 꾸준함이 중요하니까요!"]
            }
        } else {
            if weekly.difference >= 5 {
                analysis += ["지난주보다 \(weekly.difference)개 줄었어요. 요즘 좀 바빴던 건 아닐까요?",
                             "잠깐 쉬어가는 것도 괜찮아요. 다음 주엔 다시 도전해봐요 💛"]
            } else {
                analysis += ["지난주보다 조금 줄었지만, 괜찮아요. 다시 리듬을 찾으면 돼요 🍀",
                             "\(String(format: "%.1f", weekly.percentage))% 감소했어요."]
            }
        }
        
        return analysis
    }
    
    func generateMonthlyAnalysis() -> [String] {
        let monthly = calculateChangeFromPrevious(current: completedStats, previous: previousCompletedStats)
        
        let rangeInfo = monthlyChangeDateRangeString()
        
        var analysis: [String] = [rangeInfo]
        
        if monthly.isSame {
            analysis += ["지난달과 같은 루틴 수행량이에요.",
                         "꾸준함이 가장 어려운데, 정말 잘하고 있어요! 👏"]
        } else if monthly.isIncreased {
            if monthly.difference >= 15 {
                analysis += ["지난달보다 \(monthly.difference)개 더 완료했어요! 😍",
                             "\(String(format: "%.1f", monthly.percentage))% 상승했어요. 눈에 띄는 성장입니다!"]
            } else {
                analysis += ["조금 더 노력한 한 달이었어요! 👍",
                             "\(monthly.difference)개 늘었어요. 멋져요!"]
            }
        } else {
            if monthly.difference >= 15 {
                analysis += ["지난달보다 \(monthly.difference)개 줄었어요.",
                             "컨디션이 좋지 않았던 걸 수도 있어요. 다음 달엔 다시 회복할 수 있어요 💪"]
            } else {
                analysis += ["루틴 수행이 \(monthly.difference)개 살짝 줄었어요.",
                             "\(String(format: "%.1f", monthly.percentage))% 감소했어요. 괜찮아요, 다시 시작해봐요! 🌱"]
            }
        }
        
        return analysis
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
    
    // MARK: - FavoriteCategory
    func loadAllCategoryStats() {
        fetchTotalCompletedStatsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] stats in
                guard let self = self else { return }

                self.completedStats = stats
                
                var countByCategory: [HabitCategory: Int] = [:]
                
                for stat in stats {
                    countByCategory[stat.category, default: 0] += stat.count
                }
                
                let orderedStats = categoryDisplayOrder.compactMap { category -> (HabitCategory, Int)? in
                    guard let totalCount = countByCategory[category], totalCount > 0 else { return nil }
                    return (category, totalCount)
                }
                
                self.categoryStats = Dictionary(uniqueKeysWithValues: orderedStats)
                self.categoryStatList = orderedStats.map { (category, totalCount) in
                    CategoryStat(category: category, totalCount: totalCount)
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
            percentage: abs(percentage)
        )
    }
}
