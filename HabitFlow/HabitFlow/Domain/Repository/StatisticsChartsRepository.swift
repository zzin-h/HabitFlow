//
//  StatisticsChartsRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Foundation
import Combine

protocol StatisticsChartsRepository {
    func fetchTotalCompletedStats() -> AnyPublisher<[TotalCompletedStat], Error>
    func fetchActiveDaysStat() -> AnyPublisher<ActiveDaysStat, Error>
    func fetchCompletedDates() -> AnyPublisher<[Date], Error>
    func fetchCategoryStats() -> AnyPublisher<[CategoryStat], Error>
    func fetchBestHabitsWithCategory() -> AnyPublisher<[String: (count: Int, category: HabitCategory)], Error>
}
