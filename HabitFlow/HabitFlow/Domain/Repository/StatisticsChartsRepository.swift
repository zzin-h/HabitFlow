//
//  StatisticsChartsRepository.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/23/25.
//

import Combine

protocol StatisticsChartsRepository {
    func fetchTotalCompletedStats() -> AnyPublisher<[TotalCompletedStat], Error>
    func fetchActiveDaysStat() -> AnyPublisher<ActiveDaysStat, Error>
}
