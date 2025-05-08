//
//  StatisticsUseCase.swift
//  HabitFlow
//
//  Created by Haejin Park on 4/18/25.
//

import Foundation
import Combine

protocol StatisticsUseCase {
    func fetchTotalCompletedCount() -> AnyPublisher<Int, Error>
    func fetchActiveDays() -> AnyPublisher<(total: Int, streak: Int), Error>
    func fetchFavoriteCategory() -> AnyPublisher<String, Error>
    func fetchBestHabit() -> AnyPublisher<String, Error>
    func fetchTotalTime() -> AnyPublisher<Int, Error>
    func fetchTimeBasedStats() -> AnyPublisher<TimeBasedStats, Error>
}
